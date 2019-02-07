module ShackKit
  module Data
    class SPCalls
      LOCAL_SOURCE = '/individuals_2019-02-07.csv'
      ONLINE_SOURCES = [
        'https://amator.uke.gov.pl/individuals/export.csv?locale=en',
        'https://amator.uke.gov.pl/clubs/export.csv?locale=en'
      ]

      class << self
        def update(source_file = SOURCES_DIR + LOCAL_SOURCE, *other_source_files)
          sources = [source_file] + other_source_files
          calls = DB[:sp_calls]
          calls.delete
          sources.each do |source|
            CSV.foreach(source, col_sep: ";", encoding: "Windows-1250:UTF-8", headers: true) do |row|
              individual = row["station_city"].nil?
              calls.insert(
                callsign: row["call_sign"],
                station_type: individual ? "individual" : "club",
                club_name: content(row["enduser_name"]) || content(row["applicant_name"]),
                licence_number: row["number"],
                valid_until: Date.parse(row["valid_to"]),
                licence_category: row["category"],
                tx_power: row["transmitter_power"].to_i,
                station_location: individual ? row["station_location"] : row["station_city"]
              )
            end
          end
          calls.count
        end

        def update_online
          update(*ONLINE_SOURCES.map{ |source| open(source) })
        end

        def check(callsign)
          DB[:sp_calls].where(callsign: callsign).first
        end

        private

        def content(string)
          return nil if string.nil? || string.empty?
          string
        end
      end
    end
  end
end
