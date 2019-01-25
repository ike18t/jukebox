require "json"

module Jukebox
  module Models
    class Notification
      JSON.mapping(current_track: { type: CurrentTrack, setter: false },
                   current_user: { type: CurrentUser, setter: false },
                   play_status: { type: PlayStatus, setter: false })

      def initialize(track, user)
        @current_track = CurrentTrack.new(track)
        @current_user = CurrentUser.new(user)
        @play_status = PlayStatus.new()
      end
    end

    class CurrentTrack
      JSON.mapping(name: { type: String, setter: false },
                   artists: { type: String, setter: false },
                   album: { type: String, setter: false },
                   image: { type: String, setter: false })

      def initialize(track)
        @name = track.name
        @artists = track.artists.map{ |artist| artist.name }.join(',')
        @album = track.album.name
        @image = track.album.images[0].url
      end
    end

    class CurrentUser
      JSON.mapping(id: { type: String, setter: false },
                   name: { type: String, setter: false },
                   avatar_url: { type: String, setter: false })

      def initialize(user)
        @id = user.id
        @name = user.name
        @avatar_url = user.image_url
      end
    end

    class PlayStatus
      JSON.mapping(playing: Bool,
                   timestamp: {type: Time, converter: Time::EpochConverter})

      def initialize(playing = true)
        @playing = playing
        @timestamp = Time.now
      end
    end
  end
end
