module Autobots
  class Runner

    attr_accessor :options
    @after_hooks = []

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
      Minitest.__run reporter, @options
      Minitest.parallel_executor.shutdown
      reporter.report

      reporter.passed?
    end

    # before hook where you have parsed @options when loading tests
    def self.before_run
      host_env = @options[:env]
      if host_env.nil?
        # TODO(phu): default host needs to be set in a new env file
        host = 'rent'
        puts "No argument given for option -e \nLoading tests using default host: #{host}"
      else
        host = host_env.split(/_/)[0]
      end
      self.load_tests(host)
    end

    # only load tests you need by specifying env option in command line
    def self.load_tests(host)
      tests_dir_name = 'web_tests'
      tests_dir_full_path = Autobots.root.join(tests_dir_name).to_s
      if Dir.exists? tests_dir_full_path
        $LOAD_PATH << tests_dir_full_path
      else
        puts "Tests directory #{tests_dir_full_path} doesn't exist"
        puts "No test will run."
      end

      Dir.glob("#{tests_dir_name}/#{host}/*.rb") do |f|
        f.sub!(/^#{tests_dir_name}\//, '')
        require f
      end

      # files under subdirectories shouldn't be loaded, eg. archive/
      Dir.glob("#{tests_dir_name}/#{host}/test_cases/*.rb") do |f|
        f.sub!(/^#{tests_dir_name}\//, '')
        require f
      end
    end

  end
end
