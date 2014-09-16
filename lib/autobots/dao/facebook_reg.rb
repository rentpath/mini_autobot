module Autobots
  module DAO
    # Delete in order to reuse the ID as a new facebook user
    class FacebookReg < Base
      def facebook_del(person_id)
        result = @connection.exec('delete from external_auth_profiles_t where person_id = :1', person_id)
        unless result.nil? || result == 0
      end
      end

    # Check that facebook user is deleted
      def facebook_check(person_id)
        result = @connection.exec('select * from external_auth_profiles_t where person_id = :1', person_id)
        unless result.nil? || result == 0
          result.fetch.first
      end
      end
    end
  end
end