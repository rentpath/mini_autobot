module Autobots
  module DAO
    class Base
      def initialize(connection)
        @connection = connection
      end
    end
  end
end