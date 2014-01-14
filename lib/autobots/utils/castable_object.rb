
module Autobots
  module Utils

    module CastableObject

      module ClassMethods

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

      end

      def self.included(base)
        base.extend(ClassMethods)
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

    end

  end
end

