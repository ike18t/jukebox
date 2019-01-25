require "http/client"

module Jukebox
  class Player
    def initialize(player_update_endpoint : String)
      @player_update_endpoint = player_update_endpoint
      @historian = TrackHistorian.new
    end

    @current_user : Models::User | Nil

    def start!
      play_a_song
      loop do
        cache_state = Services::CacheService(Models::PlayerState).get
        player_state = cache_state.empty? ? Models::PlayerState.new : cache_state[0]

        if Services::SpotifyService.playing? && player_state.paused?
          Services::SpotifyService.pause
        elsif !Services::SpotifyService.playing? && !player_state.paused?
          Services::SpotifyService.play
        elsif !Services::SpotifyService.playing? || player_state.skip?
          play_a_song unless player_state.paused?
          Services::CacheService(Models::PlayerState).set([Models::PlayerState.new(skip: false)]) if player_state.skip?
        end

        sleep 2
      end
    end

    private def play_a_song
      enabled_users = Services::UserService.get_enabled_users
      enabled_playlists = Services::PlaylistService.get_enabled_playlists
      @historian.update_enabled_playlists_list enabled_playlists.map { |playlist| playlist.name }
      return if enabled_users.empty?
      original_user = @current_user
      loop do
        current_user = SpinDoctor(Models::User).get_next_item enabled_users, @current_user
        @current_user = current_user
        playlists = Services::PlaylistService.get_enabled_playlists_for_user current_user.id
        return if current_user == original_user && playlists.empty?
        next if playlists.empty?
        track = get_random_track_for_playlist playlists.sample

        unless track.nil?
          @historian.pop
          Services::SpotifyService.play track.uri
          notify track, current_user
        end

        break
      end
    end

    private def get_random_track_for_playlist(playlist)
      spotify_playlist = Spotify::Playlist.find(playlist.user_id, playlist.id)
      num_tracks = spotify_playlist.tracks.total
      @historian.update_playlist_track_count(spotify_playlist.name, num_tracks)
      spotify_playlist.tracks(limit: 10, offset: rand(num_tracks)).items.each do |playlist_track|
        track = playlist_track.track
        if !@historian.played_recently?(track.artists.first.name, track.name)
          return track
        end
      end
    end

    private def notify(track, user)
      @historian.record track.artists.first.name, track.name
      puts "Now playing #{track.name} by #{track.artists.first.name} on the album #{track.album.name}"
      begin
        HTTP::Client.put(@player_update_endpoint, HTTP::Headers { "content-type" => "application/json" }, body: { now_playing: Models::Notification.new(track, user) }.to_json )
      rescue ex : Exception
        puts ex.message
      end
    end
	end
end
