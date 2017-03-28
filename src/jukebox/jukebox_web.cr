require "kemal"

module Jukebox
  class JukeboxWeb
    @@web_socket_connections = Array(HTTP::WebSocket).new

    ws "/websocket_connect" do |socket|
      @@web_socket_connections << socket
      broadcast_enabled [socket]

      socket.on_close do
        @@web_socket_connections.delete(socket)
      end
    end

    get "/" do
      File.read("public/index.html")
    end

    post "/player_endpoint" do

    end

    post "/playlists" do |env|
      playlist_url = env.params.body.fetch("playlist_url", "").to_s
      begin
        user_id, playlist_id = parse_user_id_and_playlist_id(playlist_url)
        puts user_id
        puts playlist_id
      rescue Exception
        env.response.status_code = 400
        next
      end

      new_playlist = Services::PlaylistService.create_playlist(user_id, playlist_id)
      Services::UserService.create_user(user_id) unless Services::UserService.user_exists? user_id
      broadcast_enabled
      env.redirect "/"
    end

    def self.parse_user_id_and_playlist_id(url)
      match_data = url.match /^.*user[\/|\:](.*)[\/|\:]playlist\/(.*)$/
      raise Exception.new if match_data.nil?

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

    put "/pause" do
      Services::SpotifyService.pause
    end

    put "/play" do
      Services::SpotifyService.pause false
    end

    put "/skip" do
    end

    private def self.broadcast_enabled(web_sockets = @@web_socket_connections)
      users = Services::UserService.get_users
      playlists = Services::PlaylistService.get_playlists
      json = { "users" => users, "playlists" => playlists }.to_json
      web_sockets.each do |web_socket|
        web_socket.send json
      end
    end

    def run
      Kemal.run
    end
  end
end
