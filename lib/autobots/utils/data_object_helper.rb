module Autobots
  module Utils
    module DataObjectHelper


      def dao(name)
        # Get the fully-qualified class name
        klass_name = "autobots/dao/#{name}".camelize
        klass = begin
          klass_name.constantize
        rescue => exc
          msg = ""
          msg << "Cannot find data access object '#{name}', "
          msg << "because could not load class '#{klass_name}' "
          msg << "with underlying error:\n  #{exc.class}: #{exc.message}\n"
          msg << exc.backtrace.map { |str| "    #{str}" }.join("\n")
          raise NameError, msg
        end

        Autobots::Connector.get_default



        # Get a connector instance and use it in the new data access object
        driver = Autobots::Connector.get(connector, env)
        instance = klass.new(driver)

        # Before visiting the page, do any pre-processing necessary, if any
        yield instance if block_given?
        instance.go!

        # Return the instance as-is
        instance
      end

      # Local teardown for data access objects. Any data access objects that are loaded will
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