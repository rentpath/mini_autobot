
module Autobots
  module Utils

    # Page object-related helper methods.
    module PageObjectHelper

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

        driver = Autobots::Connector.get(connector, env)
        instance = klass.new(driver)
        instance.go!
        instance
      end

    end

  end
end
