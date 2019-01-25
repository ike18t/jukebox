require "json"

module Jukebox
  module Models
    class User
      JSON.mapping(enabled: Bool,
                   id: { type: String, setter: false },
                   image_url: { type: String, setter: false },
                   name: { type: String, setter: false })

      def initialize(id : String, name : String, enabled : Bool, image_url : String)
        @id = id
        @name = name
        @enabled = enabled
        @image_url = image_url
      end

      def enabled?
        @enabled == true
      end
    end
  end
end
