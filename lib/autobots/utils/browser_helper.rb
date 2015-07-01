module Autobots
  module Utils

    module BrowserHelper

      # For saucelabs, it returns the OS and browser combination
      # For everything else, it returns the browser
      # @return [String]
      def current_browser
        Autobots.settings.connector.split(/:/)[-1]
      end

      def current_browser_is?(expected_browser)
        current_browser.include? expected_browser
      end

      # cube_tracking helper method
      # @param [Har, String] eg. cubetrack_value(@proxy.har, 'trackname')
      # @return [Array] values of all values for name occurred at the point when this method gets called
      def cubetrack_values(har, name)
        values = Array.new
        har.entries.each do |entry| # entries is an array of entrys
          request = entry.request
          if request.url.include? 'wh.consumersource.com' # url - 'domain' of an event
            query_str_parameters = request.query_string # an array of hashs
            query_str_parameters.each do |parameter|
              values << parameter["value"] if parameter["name"] == name
            end
          end
        end
        return values
      end

    end
    
  end
end
    
