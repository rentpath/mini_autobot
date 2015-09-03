module MiniAutobot
  class Runnable < Minitest::Runnable

    ##
    # Defines the order to run tests (:random by default). Override
    # this or use a convenience method to change it for your tests.

    def self.test_order
      :random
    end

    ##
    # Responsible for running all runnable methods in a given class,
    # each in its own instance. Each instance is passed to the
    # reporter to record.

    def self.start_run reporter, options = {}
      filter = options[:filter] || '/./'
      filter = Regexp.new $1 if filter =~ /\/(.*)\//

      filtered_methods = Minitest::Test.runnable_methods.find_all { |m|
        filter === m || filter === "#{self}##{m}"
      }

      Minitest::Test.with_info_handler reporter do
        filtered_methods.each do |method_name|
          if MiniAutobot.settings.parallel?
            @@parallelized_methods << method_name
          else
            run_one_method self, method_name, reporter
          end
        end
      end
    end
  end
  class Runner

    attr_accessor :options
    @after_hooks = []
    @@parallelized_methods = []

    def self.after_run(&blk)
      @after_hooks << blk
    end

    def self.run!(args)
      exit_code = self.run(args)
      @after_hooks.reverse_each(&:call)
      Kernel.exit(exit_code || false)
    end

    def self.run args = []
      Minitest.load_plugins

      @options = Minitest.process_args args

      self.before_run

      reporter = Minitest::CompositeReporter.new
      reporter << Minitest::SummaryReporter.new(@options[:io], @options)
      reporter << Minitest::ProgressReporter.new(@options[:io], @options)

      Minitest.reporter = reporter # this makes it available to plugins
      Minitest.init_plugins @options
      Minitest.reporter = nil # runnables shouldn't depend on the reporter, ever

      reporter.start
      # parallel execution starts here, instead of this __run below?
      self.__run reporter, @options
      require 'pry'
      binding.pry
      Minitest.parallel_executor.shutdown
      reporter.report

      reporter.passed?
    end

    ##
    # Internal run method. Responsible for telling all Runnable
    # sub-classes to run.
    #
    # NOTE: this method is redefined in parallel_each.rb, which is
    # loaded if a Runnable calls parallelize_me!.

    def self.__run reporter, options
      suites = MiniAutobot::Runnable.runnables.shuffle
      parallel, serial = suites.partition { |s| s.test_order == :parallel }

      # If we run the parallel tests before the serial tests, the parallel tests
      # could run in parallel with the serial tests. This would be bad because
      # the serial tests won't lock around Reporter#record. Run the serial tests
      # first, so that after they complete, the parallel tests will lock when
      # recording results.
      serial.map { |suite| suite.start_run reporter, options } +
          parallel.map { |suite| suite.start_run reporter, options }
    end

    # before hook where you have parsed @options when loading tests
    def self.before_run
      tests_yml_full_path = MiniAutobot.root.join('config/mini_autobot', 'tests.yml').to_s
      if File.exist? tests_yml_full_path
        self.load_tests(tests_yml_full_path)
      else
        puts "Config file #{tests_yml_full_path} doesn't exist"
        puts "mini_autobot doesn't know where your tests are located and how they are structured"
      end
    end

    # only load tests you need by specifying env option in command line
    def self.load_tests(tests_yml_full_path)
      tests_yml = YAML.load_file tests_yml_full_path

      self.check_config(tests_yml)

      tests_dir_relative_path = tests_yml['tests_dir']['relative_path']
      multi_host_flag = tests_yml['tests_dir']['multi-host']
      default_host = tests_yml['tests_dir']['default_host']
      host = @options[:env].split(/_/)[0] rescue default_host

      self.configure_load_path(tests_dir_relative_path)

      # load page_objects.rb first
      Dir.glob("#{tests_dir_relative_path}/#{multi_host_flag ? host+'/' : ''}*.rb") do |f|
        f.sub!(/^#{tests_dir_relative_path}\//, '')
        require f
      end

      # files under subdirectories shouldn't be loaded, eg. archive/
      Dir.glob("#{tests_dir_relative_path}/#{multi_host_flag ? host+'/' : ''}test_cases/*.rb") do |f|
        f.sub!(/^#{tests_dir_relative_path}\//, '')
        require f
      end
    end

    def self.check_config(tests_yml)
      raise "relative_path must be provided in #{tests_yml}" unless tests_yml['tests_dir']['relative_path'].is_a? String
      raise "multi-host must be provided in #{tests_yml}" unless [true, false].include?(tests_yml['tests_dir']['multi-host'])
      raise "default_host must be provided in #{tests_yml}" unless tests_yml['tests_dir']['default_host'].is_a? String
    end

    def self.configure_load_path(tests_dir_relative_path)
      tests_dir_full_path = MiniAutobot.root.join(tests_dir_relative_path).to_s
      if Dir.exist? tests_dir_full_path
        $LOAD_PATH << tests_dir_full_path
      else
        puts "Tests directory #{tests_dir_full_path} doesn't exist"
        puts "No test will run."
      end
    end

  end
end
