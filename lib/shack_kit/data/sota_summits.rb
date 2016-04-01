module ShackKit
  module Data
    class SOTASummits
      def self.update(source_file = SOURCES_DIR + "/summitslist.csv")
        summits = DB[:sota_summits]
        summits.delete
        csv = SimpleSpreadsheet::Workbook.read(source_file, ".csv")
        3.upto(csv.last_row) do |line|
          summits.insert(
            summit_code: csv.cell(line, 1),
            association_name: csv.cell(line, 2),
            region_name: csv.cell(line, 3),
            summit_name: csv.cell(line, 4),
            alt_m: csv.cell(line, 5).to_i,
            alt_ft: csv.cell(line, 6).to_i,
            grid_ref1: csv.cell(line, 7),
            grid_ref2: csv.cell(line, 8),
            longitude: csv.cell(line, 9).to_f,
            latitude: csv.cell(line, 10).to_f,
            points: csv.cell(line, 11).to_i,
            bonus_points: csv.cell(line, 12).to_i,
            valid_from: Date.parse(csv.cell(line, 13)),
            valid_to: Date.parse(csv.cell(line, 14)),
            activation_count: csv.cell(line, 15).to_i,
            activation_date: csv.cell(line, 16).nil? ? nil : Date.parse(csv.cell(line, 16)),
            activation_call: csv.cell(line, 17)
          )
        end
        summits.count
      end

      def self.check(reference)
        summit = DB[:sota_summits].where(summit_code: reference).first
        return false if summit.nil?
        locator = Maidenhead.to_maidenhead(summit[:latitude], summit[:longitude], 3)
        summit.merge(maidenhead_locator: locator)
      end
    end
  end
end