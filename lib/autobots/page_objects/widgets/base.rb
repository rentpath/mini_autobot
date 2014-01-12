
module Autobots
  module PageObjects
    module Widgets

      # A widget represents a portion (an element) of a page that is repeated
      # or reproduced multiple times, either on the same page, or across multiple
      # page objects or page modules.
      #
      class Base

        def initialize(page, element)
          @page = page
          @element = element
        end

      end

    end
  end
end

