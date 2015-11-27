module ShackKit
  module Data
    class SOTACalls
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
  end
end