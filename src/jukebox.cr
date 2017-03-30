require "./jukebox/**"

module Jukebox
  Spotify::Config.set_credentials(ENV["CLIENT_ID"], ENV["CLIENT_SECRET"])
  Jukebox::Services::DataStore.set SQLite3Adapter.new
  fork do
    Player.new("localhost:4567").start!
  end
  JukeboxWeb.new.run
end
