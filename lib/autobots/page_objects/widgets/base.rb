
module Autobots
  module PageObjects
    module Widgets

      # A widget represents a portion (an element) of a page that is repeated
      # or reproduced multiple times, either on the same page, or across multiple
      # page objects or page modules.
      class Base
        include Utils::CastableObject

        def initialize(page, element)
          @driver = page.driver
          @page = page
          @element = element
        end

        # Clicks on the element
        #
        # @return  [Boolean]
        def click
          @element.click
        end

      end

    end
  end
end

