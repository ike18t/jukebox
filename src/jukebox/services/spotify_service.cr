require "http/client"

module Jukebox
  module Services
    class SpotifyService
      def self.play(track_id : String | Nil = nil)
        if !track_id
          `osascript -e 'tell application "Spotify" to play'`
        else
          `osascript -e 'tell application "Spotify" to play track "#{track_id}"'`
        end
      end

      def self.playing?
        `osascript -e 'tell application "Spotify" to player state'`.chomp == "playing"
      end

      def self.pause
        `osascript -e 'tell application "Spotify" to pause'`
      end
    end
  end
end
