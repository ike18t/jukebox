require "../../spec_helper"
require "json"

describe Jukebox::Services::SpotifyService do
  describe "open" do
    it "it calls the open endpoint" do
      stub = WebMock.stub(:get, Jukebox::Services::SpotifyService::OPEN_URL)
      Jukebox::Services::SpotifyService.open
      stub.calls.should eq(1)
    end
  end

  describe "play" do
    it "should call the play url once with the correct csrf and oauth tokens" do
      track_id = "some_track_id"
      expected_csrf_token = "some_csrf_token"
      expected_oauth_token = "some_oauth_token"
      expected_play_url = Jukebox::Services::SpotifyService::PLAY_URL % { csrf_token: expected_csrf_token,
                                                                          oauth_token: expected_oauth_token,
                                                                          track_id: track_id }
      WebMock.stub(:get, Jukebox::Services::SpotifyService::CSRF_TOKEN_URL)
             .with(headers: HTTP::Headers { "Origin" => Jukebox::Services::SpotifyService::CSRF_REQUEST_ORIGIN })
             .to_return(body: { token: expected_csrf_token }.to_json)
      WebMock.stub(:get, Jukebox::Services::SpotifyService::OAUTH_TOKEN_URL)
             .to_return(body: { t: expected_oauth_token }.to_json)
      play_request_stub = WebMock.stub(:get, expected_play_url)

      Jukebox::Services::SpotifyService.play(track_id)
      play_request_stub.calls.should eq(1)
    end
  end

  describe "end_of_song?" do
    it "should return true if the playlist position is 0 and playing is false" do
      csrf_token = "some_csrf_token"
      oauth_token = "some_oauth_token"
      status_url = Jukebox::Services::SpotifyService::STATUS_URL % { csrf_token: csrf_token,
                                                                     oauth_token: oauth_token }
      WebMock.stub(:get, Jukebox::Services::SpotifyService::CSRF_TOKEN_URL)
             .to_return(body: { token: csrf_token }.to_json)
      WebMock.stub(:get, Jukebox::Services::SpotifyService::OAUTH_TOKEN_URL)
             .to_return(body: { t: oauth_token }.to_json)
      WebMock.stub(:get, status_url)
             .to_return(body: { playing_position: 0, playing: false }.to_json)

      Jukebox::Services::SpotifyService.end_of_song?.should be_truthy
    end

    it "should return false if the playlist position is not 0" do
      csrf_token = "some_csrf_token"
      oauth_token = "some_oauth_token"
      status_url = Jukebox::Services::SpotifyService::STATUS_URL % { csrf_token: csrf_token,
                                                                     oauth_token: oauth_token }
      WebMock.stub(:get, Jukebox::Services::SpotifyService::CSRF_TOKEN_URL)
             .to_return(body: { token: csrf_token }.to_json)
      WebMock.stub(:get, Jukebox::Services::SpotifyService::OAUTH_TOKEN_URL)
             .to_return(body: { t: oauth_token }.to_json)
      WebMock.stub(:get, status_url)
             .to_return(body: { playing_position: 1, playing: false }.to_json)

      Jukebox::Services::SpotifyService.end_of_song?.should be_false
    end

    it "should return false if playing is true" do
      csrf_token = "some_csrf_token"
      oauth_token = "some_oauth_token"
      status_url = Jukebox::Services::SpotifyService::STATUS_URL % { csrf_token: csrf_token,
                                                                     oauth_token: oauth_token }
      WebMock.stub(:get, Jukebox::Services::SpotifyService::CSRF_TOKEN_URL)
             .to_return(body: { token: csrf_token }.to_json)
      WebMock.stub(:get, Jukebox::Services::SpotifyService::OAUTH_TOKEN_URL)
             .to_return(body: { t: oauth_token }.to_json)
      WebMock.stub(:get, status_url)
             .to_return(body: { playing_position: 0, playing: true }.to_json)

      Jukebox::Services::SpotifyService.end_of_song?.should be_false
    end
  end

  describe "playing?" do
    it "should return true if playing" do
      csrf_token = "some_csrf_token"
      oauth_token = "some_oauth_token"
      status_url = Jukebox::Services::SpotifyService::STATUS_URL % { csrf_token: csrf_token,
                                                                     oauth_token: oauth_token }
      WebMock.stub(:get, Jukebox::Services::SpotifyService::CSRF_TOKEN_URL)
             .to_return(body: { token: csrf_token }.to_json)
      WebMock.stub(:get, Jukebox::Services::SpotifyService::OAUTH_TOKEN_URL)
             .to_return(body: { t: oauth_token }.to_json)
      WebMock.stub(:get, status_url)
             .to_return(body: { playing: true }.to_json)

      Jukebox::Services::SpotifyService.playing?.should be_truthy
    end

    it "should return false if not playing" do
      csrf_token = "some_csrf_token"
      oauth_token = "some_oauth_token"
      status_url = Jukebox::Services::SpotifyService::STATUS_URL % { csrf_token: csrf_token,
                                                                     oauth_token: oauth_token }
      WebMock.stub(:get, Jukebox::Services::SpotifyService::CSRF_TOKEN_URL)
             .to_return(body: { token: csrf_token }.to_json)
      WebMock.stub(:get, Jukebox::Services::SpotifyService::OAUTH_TOKEN_URL)
             .to_return(body: { t: oauth_token }.to_json)
      WebMock.stub(:get, status_url)
             .to_return(body: { playing: false }.to_json)

      Jukebox::Services::SpotifyService.playing?.should be_false
    end
  end

  describe "pause" do
    it "should call the pause url with true by default" do
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

      Jukebox::Services::SpotifyService.pause
      pause_request_stub.calls.should eq(1)
    end

    it "should call the pause url with false if false is provided to the pause method" do
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

      Jukebox::Services::SpotifyService.pause(false)
      pause_request_stub.calls.should eq(1)
    end
  end
end
