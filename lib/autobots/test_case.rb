
require 'active_support/inflector'

require 'autobots'

module Autobots
  class TestCase < Test::Unit::TestCase

    include Autobots::Utils::AssertionHelper
    include Autobots::Utils::PageObjectHelper

    class <<self

      attr_accessor :options

      def remove_tests(klass)
        klass.public_instance_methods.grep(/^test_/).each do |method|
          klass.send(:undef_method, method.to_sym)
        end
      end

      def sanitize_name(name)
        name.to_s.gsub(/\W+/, ' ').strip
      end

      def setup(&block)
        define_method(:setup) do
          super
          instance_eval(&block)
        end
      end

      def teardown(&block)
        define_method(:teardown) do
          setup
          instance_eval(&block)
        end
      end

      def test(name, **opts, &block)
        method_name = test_name(name)
        already_defined = instance_method(method_name) rescue false
        raise TestAlreadyDefined, "Test #{method_name} already exists in #{self}" if already_defined

        self.options ||= {}
        self.options[method_name] = opts
        if block_given?
          define_method(method_name, &block)
        else
          flunk "No implementation was provided for test '#{method_name}' in #{self}"
        end
      end

      def test_name(name)
        undercased_name = sanitize_name(name).gsub(/\s+/, '_')
        "test_#{undercased_name}".to_sym
      end

    end

    def page(name)
      klass_name = "autobots/page_objects/#{name}".camelize
      begin
        klass = klass_name.constantize
        klass.new(nil)
      rescue => exc
        raise NameError, "Cannot find use page object '#{name}', because could not load class '#{klass_name}' with underlying error #{exc.class}: #{exc.message}\n#{exc.backtrace.join("\n")}"
      end
    end

  end
end

