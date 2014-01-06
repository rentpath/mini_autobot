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
      # instance method for convenience. Raises +NameError+ if the page could
      # not be found.
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
        instance.validate!
        instance
      end

      # Given a set of arguments (no arguments by default), return the expected
      # path to the page, which must only have file path and query-string.
      def self.expected_path(*args)
        raise NotImplementedError, "expected_path is not defined for #{self}"
      end

      # Initializes a new page object from the driver. When a page is initialized,
      # no validation occurs. As such, do not call this method directly. Rather,
      # use +page(...)+ in a test case, or +cast(...)+ in another page object.
      def initialize(driver) # :nodoc:
        @driver = driver
      end

      # Attempts to create a new page object from the current driver state.
      # Raises a +NameError+ if the page could not be found.
      def cast(name)
        self.class.cast(@driver, name)
      end

      # Returns the current path loaded in the driver.
      def current_path
        URI.parse(@driver.current_url).path
      end

      # Create widgets of type +name+ from +items+, where +name+ is the widget
      # class name, and +items+ is a single or an array of WebDriver elements.
      def get_widgets!(name, items)
        return [] if items.empty?

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

      # Instructs the driver to visit the +expected_path+.
      def go!(*args)
        @driver.get(@driver.url_for(self.class.expected_path(*args)))
      end

      # Retrieves all META tags with a +name+ attribute on the current page.
      def meta
        tags = @driver.all(:css, 'meta[name]')
        tags.inject(Hash.new) do |vals, tag|
          vals[tag.attribute(:name)] = tag.attribute(:content) if tag.attribute(:name)
          vals
        end
      end

      LINK_SIGNIN="//span[@id='signin-text']/span[2]"
      INPUT_EMAIL="email_form_input"
      INPUT_PASSOWORD="password"
      BUTTON_SIGNIN="sign-in-button"

      def sign_in
        @driver.find_element(:xpath, LINK_SIGNIN.click)
        @driver.find_element(:id, INPUT_EMAIL).send_keys @QA_USERNAME
        @driver.find_element(:id, INPUT_PASSOWORD).send_keys @QA_PASSWORD
        @driver.find_element(:id, BUTTON_SIGNIN).click
      end

      def register
      end

      def sign_out
      end

      # By default, any driver state is accepted for any page. This method
      # should be overridden in subclasses.
      def validate!
        true
      end

    end
  end
end
