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
        if grid_info = details.select{ |d| d =~ /^LOKATOR\: [A-Z]{2}\d{2}/}.first
          grid = grid_info.split.last
        else
          grid = nil
        end
        { callsign: callsign, details: details, grid: grid }
      end
    end
  end
end