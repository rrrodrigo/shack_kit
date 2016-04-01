module ShackKit
  module Data
    class SOTASummits
      def self.update(source_file = SOURCES_DIR + "/summitslist.csv")
        summits = DB[:sota_summits]
        summits.delete
        CSV.foreach(source_file, headers: true, skip_lines: /SOTA Summits List/) do |row|
          summits.insert(
            summit_code: row["SummitCode"],
            association_name: row["AssociationName"],
            region_name: row["RegionName"],
            summit_name: row["SummitName"],
            alt_m: row["AltM"].to_i,
            alt_ft: row["AltFt"].to_i,
            grid_ref1: row["GridRef1"],
            grid_ref2: row["GridRef2"],
            longitude: row["Longitude"].to_f,
            latitude: row["Latitude"].to_f,
            points: row["Points"].to_i,
            bonus_points: row["BonusPoints"].to_i,
            valid_from: Date.parse(row["ValidFrom"]),
            valid_to: Date.parse(row["ValidTo"]),
            activation_count: row["ActivationCount"].to_i,
            activation_date: row["ActivationDate"].nil? ? nil : Date.parse(row["ActivationDate"]),
            activation_call: row["ActivationCall"]
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