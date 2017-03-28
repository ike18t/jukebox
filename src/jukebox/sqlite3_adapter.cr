require "db"
require "sqlite3"

module Jukebox
  class SQLite3Adapter
    DATABASE = "sqlite3://jukebox.db"

    def [](key : String) : String
      sql = "SELECT value
             FROM key_value_store
             WHERE key = ?;"
      DB.open DATABASE do |connection|
        connection.query(sql, key.to_s) do |rs|
          rs.each do
            return rs.read(String)
          end
          "{}"
        end
      end
    end

    def []=(key : String, value : String)
      sql = "INSERT OR REPLACE
             INTO key_value_store (key, value)
             VALUES (?, ?);"

      DB.open DATABASE do |connection|
        connection.exec(sql, [key, value])
      end
    end
  end
end
