module Jukebox
  class TrackHistorian
    def initialize
      @playlist_track_counts = Hash(String, Int32).new
      @track_history = Services::CacheService(Models::Track).get
      @enabled_playlists = Array(String).new
    end

    def update_enabled_playlists_list(enabled_playlists : Array(String))
      @enabled_playlists = enabled_playlists
    end

    def update_playlist_track_count(playlist_name : String, count : Int32)
      @playlist_track_counts[playlist_name] = count
    end

    def pop
      @track_history.shift
      Services::CacheService(Models::Track).set(@track_history)
    end

    def record(artist_name : String, track_name : String)
      @track_history.push(Models::Track.new(artist_name, track_name))
      @track_history.shift if @track_history.size > get_calculated_size
      Services::CacheService(Models::Track).set(@track_history)
    end

    def played_recently?(artist_name : String, track_name : String)
      !@track_history.index(Models::Track.new(artist_name, track_name)).nil?
    end

    protected def get_calculated_size : Int32
      (@enabled_playlists.reduce(0) { |count, playlist| count + (@playlist_track_counts.fetch(playlist, 0)) } * 0.50).to_i
    end
  end
end
