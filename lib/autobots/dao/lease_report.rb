module Autobots
  module DAO
    class LeaseReport < Base
      def lease_status(lease_id)
        @connection.exec("select status_xt from tbllease where lease_id = #{lease_id}") do |r|
          return r.join(',')
        end
      end
    end
  end
end