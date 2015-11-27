require "shack_kit/version"
require "fileutils"
require "sqlite3"
require "sequel"
require "simple-spreadsheet"

module ShackKit
  GEM_ROOT = File.dirname __dir__

  module Data
    DATA_DIR = ENV["HOME"] + "/.shack_kit"
    MIGRATIONS_DIR = GEM_ROOT + "/db/migrations"
    SOURCES_DIR = GEM_ROOT + "/db/sources"
    DB_FILE = DATA_DIR + "/shack_kit.db"
    DB = Sequel.sqlite(DB_FILE)
    CALLSIGN_REGEX = /\A([A-Z]{1,2}|[0-9][A-Z])([0-9])/

    class << self
      def db_setup
        FileUtils.mkpath(DATA_DIR)
        SQLite3::Database.new(DB_FILE) unless File.file?(DB_FILE)
        schema_update
        db_update
      end

      def schema_update
        Sequel.extension :migration
        Sequel::Migrator.run(DB, MIGRATIONS_DIR)
      end

      def db_update
        SotaCalls.update
        SPCalls.update
      end
    end

    class SotaCalls
      def self.update(source_file=SOURCES_DIR+"/masterSOTA.scp")
        calls = DB[:sota_calls]
        calls.delete
        File.foreach(source_file) do |line|
          callsign = line.strip
          calls.insert(callsign: callsign) if callsign =~ CALLSIGN_REGEX
        end
        calls.count
      end

      def self.include?(callsign)
        DB[:sota_calls].where(callsign: callsign).count > 0
      end
    end

    class SPCalls
      SOURCE_SHEETS = %w(Indywidualne Kluby)

      def self.update(source_file=SOURCES_DIR+"/201511\ -\ RA2WWW_ok.xls")
        calls = DB[:sp_calls]
        calls.delete
        xls = SimpleSpreadsheet::Workbook.read(source_file)
        SOURCE_SHEETS.each do |sheet_name|
          sheet_index = xls.sheets.index(sheet_name)
          xls.selected_sheet = xls.sheets[sheet_index]
          xls.first_row.upto(xls.last_row) do |row|
            next if xls.cell(row,1) == "nazwa_uke"
            calls.insert(
              callsign: xls.cell(row, 4),
              station_type: sheet_name == "Kluby" ? 'club' : 'individual',
              uke_branch: xls.cell(row, 1),
              licence_number: xls.cell(row, 2),
              valid_until: xls.cell(row, 3),
              licence_category: xls.cell(row, 5),
              tx_power: xls.cell(row, 6).to_i,
              station_location: xls.cell(row, sheet_name == "Kluby" ? 20 : 7)
            )
          end
        end
        calls.count
      end

      def self.check(callsign)
        DB[:sp_calls].where(callsign: callsign).first
      end
    end
  end
end
