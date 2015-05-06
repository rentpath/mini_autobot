# require 'oci8'

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

        # Get a connector instance and use it in the new data access object
        driver = Autobots::Connector.get_default

        # Read values from specified connector
        db_name = driver.env[:viva_db][:service]
        db_username = driver.env[:viva_db][:user]
        db_password = driver.env[:viva_db][:pass]

        # Default values for required Connection Pool params
        cpool_min_limit = 1
        cpool_max_limit = 5
        cpool_increment = 2

        cpool = Autobots::DAO::Base.pool ||= OCI8::ConnectionPool.new(cpool_min_limit, cpool_max_limit, cpool_increment, db_username, db_password, db_name)
        db_connection = OCI8.new(db_username, db_password, cpool)
        instance = klass.new(db_connection)

        # Return the instance as-is
        instance
      end

    end
  end
end