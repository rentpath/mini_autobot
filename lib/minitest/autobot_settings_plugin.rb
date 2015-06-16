module Minitest

  # Minitest plugin: autobot_settings
  #
  # This is where the options are propagated to +Autobots.settings+.
  def self.plugin_autobot_settings_init(options)
    Autobots.settings = options

    Autobots.logger = Autobots::Logger.new('autobots.log', 'daily').tap do |logger|
      logger.formatter = proc do |sev, ts, prog, msg|
        msg = msg.inspect unless String === msg
        "#{ts.strftime('%Y-%m-%dT%H:%M:%S.%6N')} #{sev}: #{String === msg ? msg : msg.inspect}\n"
      end
      logger.level = case Autobots.settings.verbosity_level
                     when 0
                       Logger::WARN
                     when 1
                       Logger::INFO
                     else
                       Logger::DEBUG
                     end
      logger.info("Booting up with arguments: #{options[:args].inspect}")
      at_exit { logger.info("Shutting down") }
    end

    Autobots::Console.bootstrap! if options[:console]

    self
  end

  # Minitest plugin: autobot_settings
  #
  # This plugin for minitest injects autobot-specific command-line arguments, and
  # passes it along to autobot.
  def self.plugin_autobot_settings_options(parser, options)
    options[:auto_finalize] = true
    parser.on('-Q', '--no-auto-quit-driver', "Don't automatically quit the driver after a test case") do |value|
      options[:auto_finalize] = value
    end

    options[:connector] = ENV['AUTOBOT_CONNECTOR'] if ENV.has_key?('AUTOBOT_CONNECTOR')
    parser.on('-c', '--connector TYPE', 'Run using a specific connector profile') do |value|
      options[:connector] = value
    end

    options[:connector] = ENV['AUTOBOT_ENV'] if ENV.has_key?('AUTOBOT_ENV')
    parser.on('-e', '--env ENV', 'Run against a specific environment') do |value|
      options[:env] = value
    end

    options[:console] = false
    parser.on('-i', '--console', 'Run an interactive session within the context of an empty test') do |value|
      options[:console] = true
    end

    options[:reuse_driver] = false
    parser.on('-r', '--reuse-driver', "Reuse driver between tests") do |value|
      options[:reuse_driver] = value
    end

    parser.on('-t', '--tag TAGLIST', 'Run only tests matching a specific tag, tags, or tagsets') do |value|
      options[:tags] ||= [ ]
      options[:tags] << value.to_s.split(',').map { |t| t.to_sym }
    end

    options[:verbosity_level] = 0
    parser.on('-v', '--verbose', 'Output verbose logs to the log file') do |value|
      options[:verbosity_level] += 1
    end

    options[:parallel] = false
    parser.on('-p', '--parallel', 'Run in parallel') do |value|
      options[:parallel] = value
    end
  end

end
