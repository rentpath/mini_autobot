module Autobots
  module DAO
    class LeaseReport < Base
      def lease_status(lease_id)
        result = @connection.exec('select status_xt from tbllease where lease_id = :1', lease_id)
        unless result.nil? || result == 0
          result.fetch.first
        end
      end
    end
  end
end