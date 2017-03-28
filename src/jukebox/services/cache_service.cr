require "json"

module Jukebox
  module Services
    class DataStore
      @@data_store : Hash(String, String) | SQLite3Adapter = Hash(String, String).new

      def self.set(store : Hash(String, String) | SQLite3Adapter)
        @@data_store = store
      end

      def self.[](key : String) : String
        @@data_store[key]
      end

      def self.[]=(key : String, value : String)
        @@data_store[key] = value
      end
    end

    class CacheService(T)
      def self.clear
        DataStore[cache_key(T)] = Cache(T).new(Array(T).new).to_json
      end

      def self.get : Array(T)
        begin
          value = DataStore[cache_key(T)]
        rescue KeyError
          Array(T).new
        end
        value.nil? ? Array(T).new : Cache(T).from_json(value).items
      end

      def self.set(values : Array(T))
        DataStore[cache_key(T)] = Cache(T).new(values).to_json
      end

      private def self.cache_key(class_name) : String
        class_name.to_s.split("::").last.downcase
      end

      private class Cache(T)
        def initialize(values : Array(T))
          @items = values
        end

        JSON.mapping(items: { type: Array(T), default: Array(T).new })
      end

    end
  end
end
