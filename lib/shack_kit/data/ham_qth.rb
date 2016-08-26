module ShackKit
  module Data
    class HamQTH
      attr_reader :session_key
      QUERY_URL = 'https://www.hamqth.com/xml.php'

      def initialize(params = {})
        return false unless params[:login] && params[:password] || CONFIG && CONFIG.has_key?('ham_qth')
        login = params[:login] || CONFIG['ham_qth']['login']
        password = params[:password] || CONFIG['ham_qth']['password']
        response = HTTP.get("#{QUERY_URL}?u=#{login}&p=#{password}")
        parsed_response = Oga.parse_xml(response.to_s)
        @session_key = parsed_response.xpath("HamQTH/session/session_id").text
        puts parsed_response.xpath("HamQTH/session/error").text if @session_key.empty?
      end

      def lookup(callsign)
        return { error: "Can't query HamQTH.com without submitting valid login credentials first" } if @session_key.nil? || @session_key.empty?
        response = HTTP.get("#{QUERY_URL}?id=#{@session_key}&callsign=#{callsign}&prg=#{USER_AGENT}")
        parsed_response = Oga.parse_xml(response.to_s)
        return { error: parsed_response.xpath("HamQTH/session/error").text } if
          parsed_response.xpath("HamQTH/search").text.empty?
        attributes = parsed_response.xpath("HamQTH/search").first.children.select{ |c| c.class == Oga::XML::Element }.map(&:name)
        {}.tap do |output|
          attributes.each do |attribute|
            output[attribute.to_sym] = parsed_response.xpath("HamQTH/search/#{attribute}").text
          end
        end
      end
    end
  end
end