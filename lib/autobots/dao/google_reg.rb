module Autobots
  module DAO
    # Delete in order to reuse the ID as a new google plus user
    class GoogleReg < Base
      def google_del(person_id)
        result = @connection.exec('delete from external_auth_profiles_t where person_id = :1', person_id)
        @connection.commit;
        unless result.nil? || result == 0
      end
      end

    # Check that google plus user is deleted
      def google_check(person_id)
        result = @connection.exec('select EMAIL from external_auth_profiles_t where person_id = :1', person_id)
        unless result.nil? || result == 0
          result.fetch.first
      end
      end
    end
  end
end