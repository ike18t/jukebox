require "spotify"

module Jukebox
  module Services
    class UserService
      def self.create_user(id) : Models::User
        spotify_user = Spotify::User.find(id)
        new_user = Models::User.new(id, spotify_user.display_name, true, spotify_user.images[0].url)
        save_users(get_users << new_user)
        new_user
      end

      def self.get_enabled_users
        get_users.select(&.enabled?)
      end

      def self.enable_user(id)
        set_enabled id, true
      end

      def self.disable_user(id)
        set_enabled id, false
      end

      def self.get_users
        CacheService(Models::User).get
      end

      def self.user_exists?(id)
        get_users.any? { |user| user.id == id }
      end

      private def self.set_enabled(user_id, enabled)
        users = get_users
        user_index = users.index { |user| user.id == user_id }
        unless user_index.nil?
          users[user_index].enabled = enabled
          save_users users
        end
      end

      private def self.save_users(users)
        CacheService(Models::User).set users
      end
    end
  end
end
