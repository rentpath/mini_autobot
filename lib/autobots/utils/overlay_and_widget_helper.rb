module Autobots
  module Utils
    module OverlayAndWidgetHelper
      # Create widgets of type `name` from `items`, where `name` is the widget
      # class name, and `items` is a single or an array of WebDriver elements.
      #
      # @param name [#to_s] the name of the widget, under `autobots/page_objects/widgets`
      #   to load.
      # @param items [Enumerable<Selenium::WebDriver::Element>] WebDriver elements.
      # @return [Enumerable<Autobots::PageObjects::Widgets::Base>]
      # @raise NameError
      def get_widgets!(name, items)
        items = Array(items)
        return [] if items.empty?

        # Load the widget class
        klass_name = "autobots/page_objects/widgets/#{name}".camelize
        klass = begin
          klass_name.constantize
        rescue => exc
          msg = ""
          msg << "Cannot find widget '#{name}', "
          msg << "because could not load class '#{klass_name}' "
          msg << "with underlying error:\n  #{exc.class}: #{exc.message}\n"
          msg << exc.backtrace.map { |str| "    #{str}" }.join("\n")
          raise NameError, msg
        end

        page = self.page_object

        if items.respond_to?(:map)
          items.map { |item| klass.new(page, item) }
        else
          [klass.new(page, items)]
        end
      end

      # Create overlay of type `name`, where `name` is the overlay
      # class name
      #
      # @param name [#to_s] the name of the overlay, under `autobots/page_objects/widgets`
      #   to load.
      # @param items [Enumerable<Selenium::WebDriver::Element>] WebDriver elements.
      # @return [Enumerable<Autobots::PageObjects::Overlay::Base>]
      # @raise NameError
      def get_overlay!(name)
        # Load the Overlay class
        klass_name = "autobots/page_objects/overlay/#{name}".camelize
        klass = begin
          klass_name.constantize
        rescue => exc
          msg = ""
          msg << "Cannot find overlay '#{name}', "
          msg << "because could not load class '#{klass_name}' "
          msg << "with underlying error:\n  #{exc.class}: #{exc.message}\n"
          msg << exc.backtrace.map { |str| "    #{str}" }.join("\n")
          raise NameError, msg
        end
        page = self.page_object
        klass.new(page)
      end


      def page_object
        raise NotImplementedError, "classes including OverlayAndWidgetHelper must override :page_object"
      end

    end #OverlayAndWidgetHelper
  end #Utils
end #Autobots
