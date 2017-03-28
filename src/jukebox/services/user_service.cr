require "spotify"

module Jukebox
  module Services
    class UserService
      def self.create_user(id) : Models::User
        spotify_user = Spotify::User.find(id)
        new_user = Models::User.new(id, spotify_user.display_name, true)
        save_users(get_users << new_user)
        new_user
      end
      # def self.create_user(user_id)
      #   users = get_users
      #   if users.select { |u| u.id == user_id }.empty?
      #     user_name = get_name(user_id)
      #     user = User.new user_id, user_name, true
      #     users << user
      #     save_users users
      #   end
      #   user
      # end

      # def self.get_enabled_users
      #   get_users.select(&:enabled?)
      # end

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

      # private def self.get_name(user_id)
      #   spotify_user = Spotify::User.find(user_id)
      #   spotify_user.display_name
      # end

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
