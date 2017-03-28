require "../spec_helper"

describe Jukebox::TrackHistorian do
  describe "record" do
    it "adds track info to the track cache" do
      historian = Jukebox::TrackHistorian.new
      historian.update_enabled_playlists_list(["whatevs"])
      historian.update_playlist_track_count("whatevs", 2)
      historian.record("weezer", "say it ain't so")

      cache = Jukebox::Services::CacheService(Jukebox::Models::Track).get
      cache.first.artist_name.should eq("weezer")
      cache.first.track_name.should eq("say it ain't so")
    end

    it "does not add the track to the track cache if enabled playlist track count is less than double" do
      historian = Jukebox::TrackHistorian.new
      historian.update_enabled_playlists_list(["whatevs"])
      historian.update_playlist_track_count("whatevs", 1)
      historian.record("weezer", "say it ain't so")

      Jukebox::Services::CacheService(Jukebox::Models::Track).get.size.should eq(0)
    end
  end

  describe "pop" do
    it "should take the first track off of cache" do
      historian = Jukebox::TrackHistorian.new
      historian.update_enabled_playlists_list(["whatevs"])
      historian.update_playlist_track_count("whatevs", 50)
      historian.record("weezer", "say it ain't so")
      historian.record("weezer", "hash pipe")
      historian.pop

      cache = Jukebox::Services::CacheService(Jukebox::Models::Track).get
      cache.size.should eq(1)
      cache.first.artist_name.should eq("weezer")
      cache.first.track_name.should eq("hash pipe")
    end
  end

  describe "played_recently?" do
    it "should return true if the track is in the cache" do
      historian = Jukebox::TrackHistorian.new
      historian.update_enabled_playlists_list(["whatevs"])
      historian.update_playlist_track_count("whatevs", 50)
      historian.record("weezer", "hash pipe")
      historian.played_recently?("weezer", "hash pipe").should be_truthy
    end

    it "should return false if the track is not in the cache" do
      historian = Jukebox::TrackHistorian.new
      historian.played_recently?("weezer", "hash pipe").should be_falsey
    end
  end
end
