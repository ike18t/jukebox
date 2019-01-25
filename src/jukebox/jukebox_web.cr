require "kemal"

module Jukebox
  class JukeboxWeb
		@@web_socket_connections = Array(HTTP::WebSocket).new
		@@currently_playing : Models::Notification | Nil

    ws "/websocket_connect" do |socket|
      @@web_socket_connections << socket
      broadcast_enabled [socket]
      broadcast @@currently_playing, [socket] if @@currently_playing

      socket.on_close do
        @@web_socket_connections.delete(socket)
      end
    end

    get "/" do
      File.read("public/index.html")
    end

    put "/player_endpoint" do |env|
      currently_playing = Models::Notification.from_json(env.params.json["now_playing"].as(Hash(String, JSON::Any)).to_json)
			puts currently_playing
      set_current(currently_playing)
			broadcast currently_playing
    end

    put "/playlists/:playlist_id/enable" do |env|
      playlist_id = env.params.url["playlist_id"]
      Services::PlaylistService.enable_playlist playlist_id
      broadcast_enabled
    end

    put "/playlists/:playlist_id/disable" do |env|
      playlist_id = env.params.url["playlist_id"]
      Services::PlaylistService.disable_playlist playlist_id
      broadcast_enabled
    end

    post "/playlists" do |env|
      playlist_url = env.params.body.fetch("playlist_url", "").to_s
      begin
        user_id, playlist_id = parse_user_id_and_playlist_id(playlist_url)
        puts user_id
        puts playlist_id
      rescue e : Exception
        puts e.message
        env.response.status_code = 400
        next
      end

      new_playlist = Services::PlaylistService.create_playlist(user_id, playlist_id)
      Services::UserService.create_user(user_id) unless Services::UserService.user_exists? user_id
      broadcast_enabled
      env.redirect "/"
    end

    def self.parse_user_id_and_playlist_id(url)
      match_data = url.match /^.*user[\/|\:](.*)[\/|\:]playlist\/([^\?]+)/
      raise Exception.new "Could not parse user and playlist ids from url" if match_data.nil?

      [match_data[1], match_data[2]]
    end

    put "/users/:user_id/enable" do |env|
      user_id = env.params.url["user_id"]
      Services::UserService.enable_user user_id
      broadcast_enabled
    end

    put "/users/:user_id/disable" do |env|
      user_id = env.params.url["user_id"]
      Services::UserService.disable_user user_id
      broadcast_enabled
    end

    put "/pause" do
      Services::SpotifyService.pause
      broadcast({ play_status: Models::PlayStatus.new(false) })
    end

    put "/play" do
      Services::SpotifyService.play
      broadcast({ play_status: Models::PlayStatus.new(true) })
    end

    put "/skip" do
      Services::SpotifyService.skip
    end

    private def self.broadcast_enabled(web_sockets = @@web_socket_connections)
      users = Services::UserService.get_users
      playlists = Services::PlaylistService.get_playlists
      broadcast({ users: users, playlists: playlists }, web_sockets)
    end

    private def self.broadcast(hash, web_sockets = @@web_socket_connections)
      json = hash.to_json
      web_sockets.each do |web_socket|
        web_socket.send json
      end
    end

		private def self.set_current(playing)
			@@currently_playing = playing
		end

    def run
      Kemal.run
    end
  end
end
