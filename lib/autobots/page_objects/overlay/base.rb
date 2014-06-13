
module Autobots
  module PageObjects
    module Overlay

      # A Overlay represents a portion (an element) of a page that is repeated
      # or reproduced multiple times, either on the same page, or across multiple
      # page objects or page modules.
      class Base
        include Utils::Castable
        include Utils::BrowserHelper
      
        def initialize(page)
          @driver = page.driver
          @page = page
        end
      end

    end
  end
end

