
module Minitest

  # Minitest plugin: autobot_settings
  #
  # This is where the options are propagated to +Autobots::Settings+.
  def self.plugin_autobot_settings_init(options)
    Autobots::Settings.merge!(options)
    Autobots::Settings.symbolize_keys!
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

    parser.on('-c', '--connector TYPE', 'Run using a specific connector profile') do |value|
      options[:connector] = value
    end

    parser.on('-e', '--env ENV', 'Run against a specific environment') do |value|
      options[:env] = value
    end

    parser.on('-i', '--console', 'Run an interactive session within the context of an empty test') do |value|
      Autobots::Console.bootstrap!
    end

    parser.on('-t', '--tag TAGLIST', 'Run only tests matching a specific tag, tags, or tagsets') do |value|
      options[:tags] ||= [ ]
      options[:tags] << value.to_s.split(',').map { |t| t.to_sym }
    end
  end

end
