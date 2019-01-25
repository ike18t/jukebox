require "http/client"

module Jukebox
  module Services
    class SpotifyService
      @@playing = true;

      def self.play(track_id : String | Nil = nil)
        @@playing = true;
        if !track_id
          `osascript -e 'tell application "Spotify" to play'`
        else
          `osascript -e 'tell application "Spotify" to play track "#{track_id}"'`
        end
      end

      def self.playing?
        status = `osascript -e 'tell application "Spotify" to player state'`
        @@playing || (@@playing = status.chomp == "playing")
      end

      def self.pause : Void
        @@playing = false;
        `osascript -e 'tell application "Spotify" to pause'`
      end

      def self.skip
        `osascript -e 'tell application "Spotify" to next track'`
      end
    end
  end
end
