module ShackKit
  module Data
    class SPCalls
      SOURCE_SHEETS = %w(Indywidualne Kluby)

      def self.update(source_file = SOURCES_DIR + "/201511\ -\ RA2WWW_ok.xls")
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