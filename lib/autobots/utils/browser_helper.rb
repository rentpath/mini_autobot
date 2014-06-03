module Autobots
  module Utils

    module BrowserHelper

      # @return [boolean]
      def browser_is_ie
        userAgent = @driver.execute_script("return navigator.userAgent","").downcase
        if( !userAgent.include?('firefox') && !userAgent.include?('safari') && !userAgent.include?('chrome') )
          return true
        end
        false
      end

    end
    
  end
end
    