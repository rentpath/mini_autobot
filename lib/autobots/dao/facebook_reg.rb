module Autobots
  module DAO
    # In order to reuse the ID as a new facebook user
    class FacebookReg < Base
      def facebook_reg(person_id)
        result = @connection.exec('delete from external_auth_profiles_t where person_id = :1 ; commit', person_id)
        unless result.nil? || result == 0
          result.fetch.first
        end
      end
    end
  end
end