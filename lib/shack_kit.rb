require "shack_kit/version"
require "fileutils"
require "sqlite3"
require "sequel"

module ShackKit
  GEM_ROOT = File.dirname __dir__

  module Data
    DATA_DIR = ENV["HOME"] + "/.shack_kit"
    MIGRATIONS_DIR = GEM_ROOT + "/db/migrations"
    DB = DATA_DIR + "/shack_kit.db"

    class << self
      def db_setup
        FileUtils.mkpath(DATA_DIR)
        SQLite3::Database.new(DB) unless File.file?(DB)
        schema_update
      end

      def schema_update
        Sequel.extension :migration
        Sequel::Migrator.run(Sequel.sqlite(DB), MIGRATIONS_DIR)
      end
    end
  end

end
