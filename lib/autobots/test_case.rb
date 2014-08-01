
module Autobots

  # An Autobots-specific test case container, which extends the default ones,
  # adds convenience helper methods, and manages page objects automatically.
  class TestCase < Minitest::Test
    @@all_tests = Array.new
    @@already_executed = false

    # parallelize_me!

    # Standard exception class that signals that the test with that name has
    # already been defined.
    class TestAlreadyDefined < ::StandardError; end

    # Include helper modules
    include Autobots::Utils::AssertionHelper
    include Autobots::Utils::DataGeneratorHelper
    include Autobots::Utils::DataObjectHelper
    include Autobots::Utils::Loggable
    include Autobots::Utils::PageObjectHelper
    include Autobots::Utils::BrowserHelper

    class <<self

      # @!attribute [rw] options
      #   @return [Hash] test case options
      attr_accessor :options

      # Explicitly remove _all_ tests from the current class. This will also
      # remove inherited test cases.
      #
      # @return [TestCase] self
      def remove_tests
        klass = class <<self; self; end
        public_instance_methods.grep(/^test_/).each do |method|
          klass.send(:undef_method, method.to_sym)
        end
        self
      end

      # Call this at the top of your test case class in order to run all tests
      # in alphabetical order
      #
      # @return [TestCase] self
      # @example
      #   class SomeName < TestCase
      #     run_in_order!
      #
      #     test :feature_search_01 { ... }
      #     test :feature_search_02 { ... }
      #   end
      def run_in_order!
        # `self` is the class, so we want to reopen the metaclass instead, and
        # redefine the methods there
        class <<self
          undef_method :test_order if method_defined? :test_order
          define_method :test_order do
            :alpha
          end
        end

        # Be nice and return the class back
        self
      end

      # Filter out anything not matching our tag selection, if any.
      #
      # @return [Enumerable<Symbol>] the methods marked runnable
      def runnable_methods
        methods  = super
        selected = Autobots::Settings[:tags]

        # run tests in parallel when option "-p" is provided in command line
        is_parallel = true if Autobots::Settings[:parallel]
        if is_parallel
          # check this because I don't know why this runnable_methods gets called three times consecutively when one starts running tests
          if @@already_executed
            exit
          end
          parallel = Parallel.new(nil, @@all_tests)
          # todo get the number value from "-p=" and replace nil with it
          # first parameter comes from number after "-p=", may be null(then will use default 15)
          parallel.run_in_parallel!
          @@already_executed = true
        end

        # If no tags are selected, run all tests
        return methods if selected.nil? || selected.empty?

        return methods.select do |method|
          # If the method's tags match any of the tag sets, allow it to run
          selected.any? do |tag_set|
            # Retrieve the tags for that method
            method_options = self.options[method.to_sym] rescue nil
            tags           = method_options[:tags]       rescue nil

            # If the method's tags match ALL of the tags in the tag set, allow
            # it to run; in the event of a problem, allow the test to run
            tag_set.all? do |tag|
              if tag =~ %r/^!/
                !tags.include?(tag[%r/^!(.*)/,1].to_sym) || nil
              else
                tags.include?(tag.to_sym) || nil
              end rescue true
            end
          end
        end
      end

      # Install a setup method that runs before every test.
      #
      # @return [void]
      def setup(&block)
        define_method(:setup) do
          super()
          instance_eval(&block)
        end
      end

      # Install a teardown method that runs after every test.
      #
      # @return [void]
      def teardown(&block)
        define_method(:teardown) do
          super()
          instance_eval(&block)
        end
      end

      # Defines a test case.
      #
      # It can take the following options:
      #
      # * `tags`: An array of any number of tags associated with the test case.
      #          When not specified, the test will always be run even when only
      #          certain tags are run. When specified but an empty array, the
      #          test will only be run if all tags are set to run. When the array
      #          contains one or more tags, then the test will only be run if at
      #          least one tag matches.
      # * `serial`: An arbitrary string that is used to refer to all a specific
      #            test case. For example, this can be used to store the serial
      #            number for the test case.
      #
      # @param name [String, Symbol] an arbitrary but unique name for the test,
      #   preferably unique across all test classes, but not required
      # @param opts [Hash]
      # @param block [Proc] the testing logic
      # @return [void]
      def test(name, **opts, &block)
        # Ensure that the test isn't already defined to prevent tests from being
        # swallowed silently
        method_name = test_name(name)
        check_not_defined!(method_name)

        # Add an additional tag, which is unique for each test class, to all tests
        # To allow user to run tests with option '-t t_classNameOfTheTest' without duplicate run
        opts[:tags] << ('t_'+class_name.downcase).to_sym

        # Flunk unless a logic block was provided
        if block_given?
          self.options ||= {}
          self.options[method_name.to_sym] = opts.deep_symbolize_keys
          define_method(method_name, &block)
        else
          flunk "No implementation was provided for test '#{method_name}' in #{self}"
        end
        if ( not_cube_tracking(method_name) rescue true ) # try to exclude cube_tracking tests
          @@all_tests << method_name # add all tests to @@all_tests
        end
      end

      # Check if a method_name presents as a test in cube_tracking.rb
      # @param [Symbol]
      # @return [Boolean]
      def not_cube_tracking(method_name)
        File.open("lib/autobots/test_cases/cube_tracking.rb", 'r').each_line do |line|
          if line.include?("test :"+method_name.to_s[5..-1])
            return false
          end
        end
        return true
      end

      # Check that +method_name+ hasn't already been defined as an instance
      # method in the current class, or in any superclasses.
      #
      # @param method_name [Symbol] the method name to check
      # @return [void]
      protected
      def check_not_defined!(method_name)
        already_defined = instance_method(method_name) rescue false
        raise TestAlreadyDefined, "Test #{method_name} already exists in #{self}" if already_defined
      end

      # Transform the test +name+ into a snake-case name, prefixed with "test_".
      #
      # @param name [#to_s] the test name
      # @return [Symbol] the transformed test name symbol
      # @example
      #   test_name(:search_zip) # => :test_search_zip
      private
      def test_name(name)
        undercased_name = sanitize_name(name).gsub(/\s+/, '_')
        "test_#{undercased_name}".to_sym
      end

      # Sanitize the +name+ by removing consecutive non-word characters into a
      # single whitespace.
      #
      # @param name [#to_s] the name to sanitize
      # @return [String] the sanitized value
      # @example
      #   sanitize_name('The Best  Thing [#5]') # => 'The Best Thing 5'
      #   sanitize_name(:ReallySuper___awesome) # => 'ReallySuper Awesome'
      private
      def sanitize_name(name)
        name.to_s.gsub(/\W+/, ' ').strip
      end

    end

  end

end

