
module Autobots
  # A global, singleton object that preserves runtime settings. Normally, we
  # would avoid using a root object pattern, but settings are simple and
  # ubiquitous in its use in the test framework.
  #
  # Furthermore, Minitest doesn't provide any good way of passing a hash of
  # options to each test.
  #
  # TODO: We're importing ActiveSupport's extensions to Hash, which means that
  # we'll be amending the way Hash objects work; once AS updates themselves to
  # ruby 2.0 refinements, let's move towards that.
  class Settings < ::Hash
    include Singleton

    class <<self
      undef_method :[]

      # Inspect the singleton object's contents.
      #
      # @param args [Enumerable<Object>]
      # @return [String]
      def inspect(*args)
        self.instance.inspect(*args)
      end

      # Delegate to pass all method calls to the singleton object.
      def method_missing(name, *args, &block)
        self.instance.send(name, *args, &block)
      end

      # Message responder to pass all method calls to the singleton object.
      def respond_to?(name, include_private = false)
        self.instance.respond_to?(name, include_private)
      end

    end

  end
end

