module Autobots
  module PageObjects
    module Widgets

      # A widget represents a portion (an element) of a page that is repeated
      # or reproduced multiple times, either on the same page, or across multiple
      # page objects or page modules.
      class Base
        include Utils::Castable
        include Utils::PageObjectHelper
        include Utils::BrowserHelper
        include Utils::WidgetHelper

        def initialize(page, element)
          @driver = page.driver
          @page = page
          @element = element
        end

        ## for widgets that include Utils::WidgetHelper
        def page_object
          @page
        end

        attr_reader :driver
        attr_reader :element

        # Explicitly wait for a certain condition to be true:
        #
        #   wait.until { @driver.find_element(:css, 'body.tmpl-srp') }
        def wait(opts = {})
          Selenium::WebDriver::Wait.new(opts)
        end
      end

    end
  end
end

