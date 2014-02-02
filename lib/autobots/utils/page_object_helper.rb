
module Autobots
  module Utils

    # Page object-related helper methods.
    module PageObjectHelper

      # Helper method to instantiate a new page object. This method should only
      # be used when first loading; subsequent page objects are automatically
      # instantiated by calling #cast on the page object.
      #
      # @param name [String, Symbol]
      # @return [PageObject::Base]
      def page(name)
        # Get the fully-qualified class name
        klass_name = "autobots/page_objects/#{name}".camelize
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

        # Get a default connector
        driver = Autobots::Connector.get_default
        instance = klass.new(driver)

        # Before visiting the page, do any pre-processing necessary, if any,
        # but only visit the page if the pre-processing succeeds
        if block_given?
          retval = yield instance
          instance.go! if retval
        else
          instance.go!
        end

        # Return the instance as-is
        instance
      end

      # Local teardown for page objects. Any page objects that are loaded will
      # be finalized upon teardown.
      #
      # @return [void]
      def teardown
        Autobots::Connector.finalize! if Autobots::Settings[:auto_finalize]
        super()
      end

    end

  end
end
