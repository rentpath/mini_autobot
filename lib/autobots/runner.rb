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
      begin
        $LOAD_PATH << Autobots.root.join('web_tests').to_s
      rescue
        puts "Please make sure tests exist under #{Autobots.root.join('web_tests').to_s}"
        puts "No test will run"
        break
      end

      Dir.glob("web_tests/#{host}/*.rb") do |f|
        f.sub!(/^web_tests\//, '')
        require f
      end

      # files under subdirectories shouldn't be loaded, eg. archive/
      Dir.glob("web_tests/#{host}/test_cases/*.rb") do |f|
        f.sub!(/^web_tests\//, '')
        require f
      end
    end

  end
end
