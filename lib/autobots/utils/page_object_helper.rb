
module Autobots
  module Utils

    # Page object-related helper methods.
    module PageObjectHelper

      # Helper method to instantiate a new page object. This method should
      # only be used when first loadingl subsequent page objects are automatically
      # instantiated by calling #cast on the page object.
      def page(name)
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

        connector = Autobots::Settings[:connector] || :ghost
        env = Autobots::Settings[:env] || :qa

        Autobots.logger.debug("Instantiating page(#{name}) with (#{connector}, #{env})")

        driver = Autobots::Connector.get(connector, env)
        instance = klass.new(driver)
        instance.go!
        instance
      end

      # Local teardown for page objects. Any page objects that are loaded will
      # be finalized upon teardown.
      def teardown
        Autobots::Connector.finalize! if Autobots::Settings[:auto_finalize]
        super()
      end

    end

  end
end
