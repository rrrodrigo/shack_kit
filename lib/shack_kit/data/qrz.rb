module ShackKit
  module Data
    class QRZ
      attr_reader :session_key
      QUERY_URL = 'https://xmldata.qrz.com/xml/'

      def initialize(params = {})
        return false unless params[:login] && params[:password] || ShackKit::Data::CONFIG && ShackKit::Data::CONFIG.has_key?('qrz_com')
        login = params[:login] || ShackKit::Data::CONFIG['qrz_com']['login']
        password = params[:password] || ShackKit::Data::CONFIG['qrz_com']['password']
        response = HTTP.post("#{QUERY_URL}/current/", form: { username: login, password: password, agent: "Ruby-gem-shack_kit-#{ShackKit::VERSION}" })
        parsed_response = Oga.parse_xml(response.to_s)
        @session_key = parsed_response.xpath("QRZDatabase/Session/Key").text
        puts parsed_response.xpath("QRZDatabase/Session/Error").text if @session_key.empty?
      end

      def lookup(callsign)
        return { error: "Can't query qrz.com, use valid login credentials to get access" } if @session_key.nil? || @session_key.empty?
        response = HTTP.post("#{QUERY_URL}/current/", form: { s: @session_key, callsign: callsign })
        parsed_response = Oga.parse_xml(response.to_s)
        return { error: parsed_response.xpath("QRZDatabase/Session/Error").text } if
          parsed_response.xpath("QRZDatabase/Callsign").text.empty?
        attributes = parsed_response.xpath("QRZDatabase/Callsign").first.children.select{ |c| c.class == Oga::XML::Element }.map(&:name)
        {}.tap do |output|
          attributes.each do |attribute|
            output[attribute.to_sym] = parsed_response.xpath("QRZDatabase/Callsign/#{attribute}").text
          end
          output[:message] = parsed_response.xpath('QRZDatabase/Session/Message').text
        end
      end
    end
  end
end