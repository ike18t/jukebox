require "spec"
require "webmock"
require "spec-kemal"
require "../src/jukebox/**"

Spec.before_each do
  WebMock.reset
  Jukebox::Services::DataStore.set Hash(String, String).new
end
