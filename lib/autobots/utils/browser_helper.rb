module Autobots
  module Utils

    module BrowserHelper

      # return true only if test is running on ghost driver
      # @return [boolean]
      def browser_is_ghost?
        Autobots.settings.connector.include? 'ghost'
      end

      # return true only if test is running on IE
      # @return [boolean]
      def browser_is_ie?
        Autobots.settings.connector.include? 'ie'
      end

      def browser_is_ie_8?
        Autobots.settings.connector.include? 'ie8'
      end

      # return true only if test is running on firefox
      # @return [boolean]
      def browser_is_firefox?(version_regexp: nil)
        userAgent = @driver.execute_script("return navigator.userAgent","").downcase
        if( userAgent.include?('firefox') )
          if !version_regexp.nil?
            return true if userAgent.match(version_regexp)
            return false
          end
          return true
        end
        false
      end

      # return true only if test is running on chrome
      # @return [boolean]
      def browser_is_chrome?
        Autobots.settings.connector.include? 'chrome'
      end

      # return true only if test is running on safari
      # @return [boolean]
      def browser_is_safari?
        Autobots.settings.connector.include? 'safari'
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
    
