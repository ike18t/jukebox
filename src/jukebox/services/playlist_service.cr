require "spotify"

module Jukebox
  module Services
    class PlaylistService
      def self.create_playlist(user_id, id) : Models::Playlist
        spotify_playlist = Spotify::Playlist.find(user_id, id)
        new_playlist = Models::Playlist.new(id, spotify_playlist.name, spotify_playlist.uri, user_id, true)
        puts new_playlist
        save_playlists(get_playlists << new_playlist)
        new_playlist
      end

      def self.disable_playlist(id)
        set_enabled id, false
      end

      def self.enable_playlist(id)
        set_enabled id, true
      end

      private def self.set_enabled(playlist_id, enabled)
        playlists = get_playlists
        playlist_index = playlists.index { |playlist| playlist.id == playlist_id }
        unless playlist_index.nil?
          playlists[playlist_index].enabled = enabled
          save_playlists playlists
        end
      end

      def self.get_playlists
        CacheService(Models::Playlist).get
      end

      private def self.save_playlists(playlists)
        CacheService(Models::Playlist).set playlists
      end
    end
  end
end
