
module Autobots
  module PageObjects
    module Overlay

      # A Overlay represents a portion (an element) of a page that is repeated
      # or reproduced multiple times, either on the same page, or across multiple
      # page objects or page modules.
      class Base
        include Utils::Castable
        include Utils::BrowserHelper
        include Utils::PageObjectHelper
        include Utils::OverlayAndWidgetHelper

        attr_reader :driver

        def initialize(page)
          @driver = page.driver
          @page = page
        end

        ## for overlay that include Utils::OverlayAndWidgetHelper
        def page_object
          @page
        end

        # By default, any driver state is accepted for any page. This method
        # should be overridden in subclasses.
        def validate!
          true
        end

        # Explicitly wait for a certain condition to be true:
        #   wait.until { driver.find_element(:css, 'body.tmpl-srp') }
        # when timeout is not specified, default timeout 5 sec will be used
        # when timeout is larger than 15, max timeout 15 sec will be used
        def wait(opts = {})
          if !opts[:timeout].nil? && opts[:timeout] > 15
            puts "WARNING: #{opts[:timeout]} sec timeout is NOT supported by wait method,
                max timeout 15 sec will be used instead"
            opts[:timeout] = 15
          end
          Selenium::WebDriver::Wait.new(opts)
        end

      end

    end
  end
end

