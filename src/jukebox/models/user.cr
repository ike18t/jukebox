require "json"

module Jukebox
  module Models
    class User
      JSON.mapping(enabled: Bool,
                   id: { type: String, setter: false },
                   name: { type: String, setter: false })

      def initialize(id : String, name : String, enabled : Bool)
        @id = id
        @name = name
        @enabled = enabled
      end

      def enabled?
        @enabled == true
      end
    end
  end
end
