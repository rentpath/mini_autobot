require 'selenium-webdriver'

module Selenium
  module WebDriver

    class Element

      def ie_safe_click
        bridge.browser == :internet_explorer ? send_keys(:enter) : click
      end

      def ie_safe_checkbox_click
        bridge.browser == :internet_explorer ? send_keys(:space) : click
      end

    end

  end
end
