require 'selenium-webdriver'

module Selenium
  module WebDriver

    ##
    # Monkey Patch to add ie_safe_click method to webdriver
    #
    class Element

      def ie_safe_click
        bridge.browser == :internet_explorer ? send_keys(:enter) : click
      end

    end

  end
end
