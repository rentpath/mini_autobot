module MiniAutobot
  class Connector

    # Simple configuration container for all profiles. Struct is not used here
    # because it contaminates the class with Enumerable methods, which will
    # cause #method_missing in Connector to get confused.
    class Config
      attr_accessor :connector, :env

      def ==(other)
        self.class == other.class && self.connector == other.connector && self.env == other.env
      end

      alias_method :eql?, :==

      # Hashing mechanism should only look at the connector and environment values
      def hash
        @connector.hash ^ @env.hash
      end

      # Initialize a new configuration object. This object should never be
      # instantiated directly.
      #
      # @api private
      def initialize(connector, env)
        @connector = connector
        @env = env
      end

    end

  end
end
