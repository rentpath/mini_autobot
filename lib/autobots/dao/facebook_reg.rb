module Autobots
  module DAO
    # In order to reuse the ID as a new facebook user
    class FacebookReg < Base
      def facebook_reg(person_id)
        result = @connection.exec('select * from tblperson where person_id = :1', person_id)
        unless result.nil? || result == 0
          result.fetch.first
        end
      end
    end
  end
end