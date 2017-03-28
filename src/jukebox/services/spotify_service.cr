require "http/client"
require "json"

module Jukebox
  module Services
    class SpotifyService
      OPEN_URL = "https://whatever.spotilocal.com:4370/remote/open.json"
      PLAY_URL = "https://whatever.spotilocal.com:4371/remote/play.json?csrf=%{csrf_token}&oauth=%{oauth_token}&uri=spotify:track:%{track_id}"
      STATUS_URL = "https://whatever.spotilocal.com:4371/remote/status.json?csrf=%{csrf_token}&oauth=%{oauth_token}"
      PAUSE_URL = "https://whatever.spotilocal.com:4371/remote/pause.json?csrf=%{csrf_token}&oauth=%{oauth_token}&pause=%{pause}"
      OAUTH_TOKEN_URL = "https://open.spotify.com/token"
      CSRF_TOKEN_URL = "https://whatever.spotilocal.com:4371/simplecsrf/token.json?&ref=&cors="
      CSRF_REQUEST_ORIGIN = "https://embed.spotify.com"
      DEFAULT_ORIGIN = "https://nowhere.spotify.com"

      def self.open
        make_the_call OPEN_URL
      end

      def self.play(track_id)
        play_url = PLAY_URL % { csrf_token: get_csrf_token,
                                oauth_token: get_oauth_token,
                                track_id: track_id }
        make_the_call play_url
      end

      def self.end_of_song?
        status_url = STATUS_URL % { csrf_token: get_csrf_token,
                                    oauth_token: get_oauth_token }
        response_body = make_the_call status_url
        response = JSON.parse(response_body.to_s)
        response["playing_position"] == 0 && !response["playing"].as_bool
      end

      def self.playing?
        status_url = STATUS_URL % { csrf_token: get_csrf_token,
                                    oauth_token: get_oauth_token }
        response_body = make_the_call status_url
        JSON.parse(response_body.to_s)["playing"]
      end

      def self.pause(pause=true)
        pause_url = PAUSE_URL % { csrf_token: get_csrf_token,
                                  oauth_token: get_oauth_token,
                                  pause: pause }
        make_the_call pause_url
      end

      private def self.make_the_call(url : String, headers = Hash(String, String).new)
        attempts = 0
        while(attempts < 5)
          begin
            attempts += 1
            response = HTTP::Client.get url, HTTP::Headers { "Origin" => headers.fetch(:Origin, DEFAULT_ORIGIN) }
            return response.body
          rescue e: Exception
            puts e
            open
            sleep 10
          end
        end
      end

      private def self.get_oauth_token
        response_body = make_the_call(OAUTH_TOKEN_URL)
        JSON.parse(response_body.to_s)["t"]
      end

      private def self.get_csrf_token
        response_body = make_the_call(CSRF_TOKEN_URL, { Origin: CSRF_REQUEST_ORIGIN })
        JSON.parse(response_body.to_s)["token"]
      end
    end
  end
end
