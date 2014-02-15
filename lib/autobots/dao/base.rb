module Autobots
  module DAO
    class Base
      def initialize(connection)
        @connection = connection
      end

      @@pool = nil
      def self.pool
        @@pool
      end

      def self.pool=(pool)
        @@pool = pool
      end
    end
  end
end