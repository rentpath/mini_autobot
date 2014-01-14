require 'minitest/assertions'

module Autobots
  module PageObjects

    # The base page object. All page objects should be a subclass of this.
    # Every subclass must implement the following class methods:
    #
    #   expected_path
    #
    # All methods added here will be available to all subclasses, so do so
    # sparingly.  This class has access to assertions, which should only be
    # used to validate the page.
    class Base
      include Minitest::Assertions

      # Attempts to create a new page object from a driver state. Use the
      # instance method for convenience. Raises `NameError` if the page could
      # not be found.
      #
      # @param driver [Selenium::WebDriver] The instance of the current
      #   WebDriver.
      # @param name [#to_s] The name of the page object to instantiate.
      # @return [Base] A subclass of `Base` representing the page object.
      # @raise InvalidPageState if the page cannot be casted to
      # @raise NameError if the page object doesn't exist
      def self.cast(driver, name)
        # Transform the name string into a file path and then into a module name
        klass_name = "autobots/page_objects/#{name}".camelize

        # Attempt to load the class
        klass = begin
          klass_name.constantize
        rescue => exc
          msg = ""
          msg << "Cannot find page object '#{name}', "
          msg << "because could not load class '#{klass_name}' "
          msg << "with underlying error:\n  #{exc.class}: #{exc.message}\n"
          msg << exc.backtrace.map { |str| "    #{str}" }.join("\n")
          raise NameError, msg
        end

        # Instantiate the class, passing the driver automatically, and
        # validates to ensure the driver is in the correct state
        instance = klass.new(driver)
        begin
          instance.validate!
        rescue Minitest::Assertion => exc
          raise InvalidePageState, "#{klass}: #{exc.message}"
        end
        instance
      end

      # Given a set of arguments (no arguments by default), return the expected
      # path to the page, which must only have file path and query-string.
      #
      # @param args [String] one or more arguments to be used in calculating
      #   the expected path, if any.
      # @return [String] the expected path.
      def self.expected_path(*args)
        raise NotImplementedError, "expected_path is not defined for #{self}"
      end

      # Initializes a new page object from the driver. When a page is initialized,
      # no validation occurs. As such, do not call this method directly. Rather,
      # use PageObjectHelper#page in a test case, or #cast in another page object.
      #
      # @param driver [Selenium::WebDriver] The WebDriver instance.
      def initialize(driver)
        @driver = driver
      end

      # The preferred way to create a new page object from the current page's
      # driver state. Raises a NameError if the page could not be found.
      #
      # @param name [String] see {Base.cast}
      # @return [Base] The casted page object.
      # @raise InvalidPageState if the page cannot be casted to
      # @raise NameError if the page object doesn't exist
      def cast(name)
        self.class.cast(@driver, name)
      end

      # Cast the page to any of the listed `names`, in order of specification.
      # Returns the first page that accepts the casting, or returns nil, rather
      # than raising InvalidPageState.
      #
      # @param names [Enumerable<String>] see {Base.cast}
      # @return [Base, nil] the casted page object, if successful; nil otherwise.
      # @raise NameError if the page object doesn't exist
      def cast_any(*names)
        # Try one at a time, swallowing InvalidPageState exceptions
        names.each do |name|
          begin
            return self.cast(name)
          rescue InvalidPageState
            # noop
          end
        end

        # Return nil otherwise
        return nil
      end

      # Returns the current path loaded in the driver.
      #
      # @return [String] The current path, without hostname.
      def current_path
        URI.parse(@driver.current_url).path
      end

      # Returns the current URL loaded in the driver.
      #
      # @return [String] The current URL, including hostname.
      def current_url
        URI.parse(@driver.current_url)
      end

      # Create widgets of type `name` from `items`, where `name` is the widget
      # class name, and `items` is a single or an array of WebDriver elements.
      #
      # @param name [#to_s] the name of the widget, under `autobots/page_objects/widgets`
      #   to load.
      # @param items [Enumerable<Selenium::WebDriver::Element>] WebDriver elements.
      # @return [Enumerable<Autobots::PageObjects::Widgets::Base>]
      # @raise NameError
      def get_widgets!(name, items)
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

        if items.respond_to?(:map)
          items.map { |item| klass.new(self, item) }
        else
          [klass.new(self, items)]
        end
      end

      # Instructs the driver to visit the {expected_path}.
      #
      # @param args [*Object] optional parameters to pass into {expected_path}.
      def go!(*args)
        @driver.get(@driver.url_for(self.class.expected_path(*args)))
      end

      # Check that the page includes a certain string.
      # 
      # @param value [String] the string to search
      # @return [Boolean]
      def include?(value)
        @driver.page_source.include?(value)
      end

      # Retrieves all META tags with a `name` attribute on the current page.
      def meta
        tags = @driver.all(:css, 'meta[name]')
        tags.inject(Hash.new) do |vals, tag|
          vals[tag.attribute(:name)] = tag.attribute(:content) if tag.attribute(:name)
          vals
        end
      end

      # By default, any driver state is accepted for any page. This method
      # should be overridden in subclasses.
      def validate!
        true
      end

    end
  end
end
