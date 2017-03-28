require "json"

module Jukebox
  module Models
    class Playlist
      JSON.mapping(id: { type: String, setter: false },
                   enabled: Bool,
                   name: { type: String, setter: false },
                   uri: { type: String, setter: false },
                   user_id: { type: String, setter: false })

      def initialize(id : String, name : String, uri : String, user_id : String, enabled : Bool)
        @id = id
        @name = name
        @uri = uri
        @user_id = user_id
        @enabled = enabled
      end

      def enabled?
        @enabled == true
      end
    end
  end
end
