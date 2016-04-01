module ShackKit
  module Data
    class SOTASummits
      def self.update(source_file = SOURCES_DIR + "summitslist.csv")
        summits = DB[:sp_summits]
        csv = SimpleSpreadsheet::Workbook.read(source_file, ".csv")
        3.upto(csv.last_row) do |line|
          summits.insert(
            summitsign: csv.cell(row, 4),
            station_type: sheet_name == "Kluby" ? 'club' : 'individual',
            uke_branch: csv.cell(row, 1),
            licence_number: csv.cell(row, 2),
            valid_until: csv.cell(row, 3),
            licence_category: csv.cell(row, 5),
            tx_power: csv.cell(row, 6).to_i,
            station_location: csv.cell(row, sheet_name == "Kluby" ? 20 : 7)
          )
        end
        summits.count
      end

      def self.check(callsign)
        DB[:sp_calls].where(callsign: callsign).first
      end
    end
  end
end