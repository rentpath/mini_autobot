module Autobots
  module Utils

    module BrowserHelper

      # return true only if test is running on IE
      # @return [boolean]
      def browser_is_ie
        userAgent = @driver.execute_script("return navigator.userAgent","").downcase
        if( !userAgent.include?('firefox') && !userAgent.include?('safari') && !userAgent.include?('chrome') )
          return true
        end
        false
      end

      # return true only if test is running on firefox
      # @return [boolean]
      def browser_is_firefox
        userAgent = @driver.execute_script("return navigator.userAgent","").downcase
        if( userAgent.include?('firefox') )
          return true
        end
        false
      end
            
    end
    
  end
end
    