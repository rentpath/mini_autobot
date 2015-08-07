module MiniAutobot
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
        # TODO(phu): default host needs to be set in a user's local env file
        host = 'rent'
        puts "No argument given for option -e \nLoading tests using default host: #{host}"
      else
        host = host_env.split(/_/)[0]
      end
      self.load_tests(host)
    end

    # only load tests you need by specifying env option in command line
    def self.load_tests(host)
      tests_yml_full_path = MiniAutobot.root.join('config', 'tests.yml').to_s
      if File.exist? tests_yml_full_path
        tests_yml = YAML.load_file tests_yml_full_path
        tests_dir_relative_path = tests_yml['tests_dir']['relative_path']
        multi_host_flag = tests_yml['tests_dir']['multi-host']
      else
        puts "Config file #{tests_yml_full_path} doesn't exist"
        puts "mini_autobot doesn't know where your tests are located and how they are structured"
      end

      tests_dir_full_path = MiniAutobot.root.join(tests_dir_relative_path).to_s
      if Dir.exist? tests_dir_full_path
        $LOAD_PATH << tests_dir_full_path
      else
        puts "Tests directory #{tests_dir_full_path} doesn't exist"
        puts "No test will run."
      end

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

  end
end
