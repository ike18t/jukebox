require "json"

module Jukebox
  module Models
    struct Track
      JSON.mapping(artist_name: { type: String, setter: false },
                   track_name: { type: String, setter: false })

      def initialize(artist_name : String, track_name : String)
        @artist_name = artist_name
        @track_name = track_name
      end
    end
  end
end
