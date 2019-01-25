require "json"

module Jukebox
  module Models
    class PlayerState
      JSON.mapping(skip: Bool,
                   paused: Bool)

      def initialize(@skip = false, @paused = false)
      end

      def paused?
        paused
      end

      def skip?
        skip
      end
    end
  end
end
