require "../../spec_helper"

describe Jukebox::Services::CacheService do
  describe "clear" do
    it "clears out the cache" do
      user = Jukebox::Models::User.new("some_id", "some_user", false)
      Jukebox::Services::CacheService(Jukebox::Models::User).set([user])
      Jukebox::Services::CacheService(Jukebox::Models::User).get.size.should eq(1)
      Jukebox::Services::CacheService(Jukebox::Models::User).clear
      Jukebox::Services::CacheService(Jukebox::Models::User).get.size.should eq(0)
    end

    it "clears out the cache for user and only user" do
      playlist = Jukebox::Models::Playlist.new("some_id", "some_playlist", "some_uri", "some_user", false)
      Jukebox::Services::CacheService(Jukebox::Models::Playlist).set([playlist])

      user = Jukebox::Models::User.new("some_id", "some_user", false)
      Jukebox::Services::CacheService(Jukebox::Models::User).set([user])

      Jukebox::Services::CacheService(Jukebox::Models::User).get.size.should eq(1)
      Jukebox::Services::CacheService(Jukebox::Models::Playlist).get.size.should eq(1)

      Jukebox::Services::CacheService(Jukebox::Models::User).clear
      Jukebox::Services::CacheService(Jukebox::Models::User).get.size.should eq(0)
      Jukebox::Services::CacheService(Jukebox::Models::Playlist).get.size.should eq(1)
    end
  end

  describe "set" do
    it "sets the value for the Object given" do
      user = Jukebox::Models::User.new("some_id", "some_user", false)
      Jukebox::Services::CacheService(Jukebox::Models::User).set([user])
      cached_user = Jukebox::Services::CacheService(Jukebox::Models::User).get.first

      cached_user.id.should eq(user.id)
      cached_user.enabled.should eq(user.enabled)
    end

    it "overrides the previous value" do
      old_user = Jukebox::Models::User.new("some_id", "some_user", false)
      Jukebox::Services::CacheService(Jukebox::Models::User).set([old_user])
      user = Jukebox::Models::User.new("some_other_id", "some_other_user", true)
      Jukebox::Services::CacheService(Jukebox::Models::User).set([user])

      Jukebox::Services::CacheService(Jukebox::Models::User).get.size.should eq(1)
      cached_user = Jukebox::Services::CacheService(Jukebox::Models::User).get.first

      cached_user.id.should eq(user.id)
      cached_user.enabled.should eq(user.enabled)
    end
  end

  describe "get" do
    it "returns an empty array if there is no cache for the thing" do
      cache = Jukebox::Services::CacheService(Jukebox::Models::User).get
      cache.size.should eq(0)
    end
  end
end
