require "../spec_helper"

describe Jukebox::JukeboxWeb do
  describe "put /users/:user_id/enable" do
    it "should enable the user" do
      ike = Jukebox::Models::User.new("ike", "", false)
      Jukebox::Services::CacheService(Jukebox::Models::User).set([ike])
      put "/users/ike/enable"

      users = Jukebox::Services::CacheService(Jukebox::Models::User).get

      response.status_code.should eq(200)
      users.first.id.should eq("ike")
      users.first.enabled?.should be_truthy
    end

    it "should not change the enable status of the user if they are already enabled" do
      ike = Jukebox::Models::User.new("ike", "", true)
      Jukebox::Services::CacheService(Jukebox::Models::User).set([ike])
      put "/users/ike/enable"

      users = Jukebox::Services::CacheService(Jukebox::Models::User).get

      response.status_code.should eq(200)
      users.first.id.should eq("ike")
      users.first.enabled?.should be_truthy
    end
  end

  describe "put /users/:user_id/disable" do
    it "should disable the user" do
      ike = Jukebox::Models::User.new("ike", "", true)
      Jukebox::Services::CacheService(Jukebox::Models::User).set([ike])
      put "/users/ike/disable"

      users = Jukebox::Services::CacheService(Jukebox::Models::User).get

      response.status_code.should eq(200)
      users.first.id.should eq("ike")
      users.first.enabled?.should be_false
    end

    it "should not change the enable status of the user if they are already disabled" do
      ike = Jukebox::Models::User.new("ike", "", false)
      Jukebox::Services::CacheService(Jukebox::Models::User).set([ike])
      put "/users/ike/disable"

      users = Jukebox::Services::CacheService(Jukebox::Models::User).get

      response.status_code.should eq(200)
      users.first.id.should eq("ike")
      users.first.enabled?.should be_false
    end
  end

  describe "put /playlists/:playlist_id/enable" do
    it "should enable the playlist" do
      playlist = Jukebox::Models::Playlist.new("ike", "", "", "", false)
      Jukebox::Services::CacheService(Jukebox::Models::Playlist).set([playlist])
      put "/playlists/ike/enable"

      playlists = Jukebox::Services::CacheService(Jukebox::Models::Playlist).get

      response.status_code.should eq(200)
      playlists.first.id.should eq("ike")
      playlists.first.enabled?.should be_truthy
    end

    it "should not change the enable status of the playlist if they are already enabled" do
      playlist = Jukebox::Models::Playlist.new("ike", "", "", "", true)
      Jukebox::Services::CacheService(Jukebox::Models::Playlist).set([playlist])
      put "/playlists/ike/enable"

      playlists = Jukebox::Services::CacheService(Jukebox::Models::Playlist).get

      response.status_code.should eq(200)
      playlists.first.id.should eq("ike")
      playlists.first.enabled?.should be_truthy
    end
  end

  describe "put /playlists/:playlist_id/disable" do
    it "should disable the playlist" do
      playlist = Jukebox::Models::Playlist.new("ike", "", "", "", true)
      Jukebox::Services::CacheService(Jukebox::Models::Playlist).set([playlist])
      put "/playlists/ike/disable"

      playlists = Jukebox::Services::CacheService(Jukebox::Models::Playlist).get

      response.status_code.should eq(200)
      playlists.first.id.should eq("ike")
      playlists.first.enabled?.should be_false
    end

    it "should not change the enable status of the playlist if they are already disabled" do
      playlist = Jukebox::Models::Playlist.new("ike", "", "", "", false)
      Jukebox::Services::CacheService(Jukebox::Models::Playlist).set([playlist])
      put "/playlists/ike/disable"

      playlists = Jukebox::Services::CacheService(Jukebox::Models::Playlist).get

      response.status_code.should eq(200)
      playlists.first.id.should eq("ike")
      playlists.first.enabled?.should be_false
    end
  end

  describe "/pause" do
    it "should cause a call to the spotify pause url" do
      csrf_token = "some_csrf_token"
      oauth_token = "some_oauth_token"
      expected_pause_url = Jukebox::Services::SpotifyService::PAUSE_URL % { csrf_token: csrf_token,
                                                                            oauth_token: oauth_token,
                                                                            pause: true }
      WebMock.stub(:get, Jukebox::Services::SpotifyService::CSRF_TOKEN_URL)
             .to_return(body: { token: csrf_token }.to_json)
      WebMock.stub(:get, Jukebox::Services::SpotifyService::OAUTH_TOKEN_URL)
             .to_return(body: { t: oauth_token }.to_json)
      pause_request_stub = WebMock.stub(:get, expected_pause_url)

      put "/pause"
      pause_request_stub.calls.should eq(1)
    end
  end

  describe "/play" do
    it "should cause a call to the spotify play url" do
      csrf_token = "some_csrf_token"
      oauth_token = "some_oauth_token"
      expected_pause_url = Jukebox::Services::SpotifyService::PAUSE_URL % { csrf_token: csrf_token,
                                                                            oauth_token: oauth_token,
                                                                            pause: false }
      WebMock.stub(:get, Jukebox::Services::SpotifyService::CSRF_TOKEN_URL)
             .to_return(body: { token: csrf_token }.to_json)
      WebMock.stub(:get, Jukebox::Services::SpotifyService::OAUTH_TOKEN_URL)
             .to_return(body: { t: oauth_token }.to_json)
      pause_request_stub = WebMock.stub(:get, expected_pause_url)

      put "/play"
      pause_request_stub.calls.should eq(1)
    end
  end
end
