require 'fileutils'
require 'sqlite3'
require 'sequel'

module ShackKit
  module Data
    DATA_DIR = ENV["HOME"] + "/.shack_kit"
    MIGRATIONS_DIR = ShackKit::GEM_ROOT + "/db/migrations"
    SOURCES_DIR = ShackKit::GEM_ROOT + "/db/sources"
    DB_FILE = DATA_DIR + "/shack_kit.db"
    DB = Sequel.sqlite(DB_FILE)
    CALLSIGN_REGEX = /\A([A-Z]{1,2}|[0-9][A-Z])([0-9])/

    class << self
      def db_setup
        FileUtils.mkpath(DATA_DIR)
        SQLite3::Database.new(DB_FILE) unless File.file?(DB_FILE)
        schema_update
      end

      def schema_update
        Sequel.extension :migration
        Sequel::Migrator.run(DB, MIGRATIONS_DIR)
      end

      def db_load
        SOTACalls.update
        SPCalls.update
      end
    end
  end
end

require 'shack_kit/data/sota_calls'
require 'shack_kit/data/sp_calls'
