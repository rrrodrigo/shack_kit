module ShackKit
  module Data
    class QRZ_PL
      QUERY_URL = "http://qrz.pl/callbook.asp"

      def self.lookup(callsign)
        response = HTTP.post("http://qrz.pl/callbook.asp", form: { "F_DOMENA": callsign })
        document = Oga.parse_html(response.to_s)
        return { error: "Not found: #{callsign}"} unless
          document.xpath('//span[contains(@class, "znak")]').text == callsign
        details = document.xpath('//span[contains(@class, "dane")]').map(&:text)
        { callsign: callsign, details: details, grid: grid_lookup(details) }
      end

      private

      def self.grid_lookup(details)
        return nil unless grid_info = details.select{ |d| d =~ /^LOKATOR\: [A-Z]{2}\d{2}/}.first
        grid_info.split.last
      end
    end
  end
end