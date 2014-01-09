
require 'active_support/inflector'
require 'autobots'

module Autobots
  class TestCase < Minitest::Test

    # Standard exception class that signals that the test with that name has
    # already been defined.
    class TestAlreadyDefined < ::StandardError; end

    # Include helper modules
    include Autobots::Utils::AssertionHelper
    include Autobots::Utils::PageObjectHelper

    class <<self

      attr_accessor :options

      # Explicitly remove _all_ tests from the class +klass+. This will also
      # remove inherited test cases.
      def remove_tests(klass)
        klass.public_instance_methods.grep(/^test_/).each do |method|
          klass.send(:undef_method, method.to_sym)
        end
      end

      # Install a setup method that runs before every test.
      def setup(&block)
        define_method(:setup) do
          super
          instance_eval(&block)
        end
      end

      # Install a teardown method that runs after every test.
      def teardown(&block)
        define_method(:teardown) do
          super
          instance_eval(&block)
        end
      end

      # Define a test case, given a +name+, which is recommended to be a symbol,
      # a set of options, and a +block+ of logic.
      #
      # The +name+ should be unique in the class, and preferably unique across
      # all the classes.
      #
      # The options should be a hash with the following keys:
      #
      # +tags+:: An array of any number of tags associated with the test case.
      #          When not specified, the test will always be run even when only
      #          certain tags are run. When specified but an empty array, the
      #          test will only be run if all tags are set to run. When the array
      #          contains one or more tags, then the test will only be run if at
      #          least one tag matches.
      # +serial+:: An arbitrary string that is used to refer to all a specific
      #            test case. For example, this can be used to store the serial
      #            number for the test case.
      def test(name, **opts, &block)
        method_name = test_name(name)
        check_not_defined!(method_name)

        self.options ||= {}
        self.options[method_name] = opts
        if block_given?
          define_method(method_name, &block)
        else
          flunk "No implementation was provided for test '#{method_name}' in #{self}"
        end
      end

      # Check that +method_name+ hasn't already been defined as an instance
      # method in the current class, or in any superclasses.
      protected
      def check_not_defined!(method_name)
        already_defined = instance_method(method_name) rescue false
        raise TestAlreadyDefined, "Test #{method_name} already exists in #{self}" if already_defined
      end

      # Transform the test +name+ into a snake-case name, prefixed with "test_".
      # For example, +:search_zip+ becomes +test_search_zip".
      private
      def test_name(name)
        undercased_name = sanitize_name(name).gsub(/\s+/, '_')
        "test_#{undercased_name}".to_sym
      end

      # Sanitize the +name+ by removing consecutive non-word characters into a
      # single whitespace.
      private
      def sanitize_name(name)
        name.to_s.gsub(/\W+/, ' ').strip
      end

    end

  end
end

