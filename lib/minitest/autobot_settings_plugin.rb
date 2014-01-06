
#require 'autobots/settings'

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
    parser.on('--connector TYPE', 'Run using a specific connector profile') do |value|
      options[:connector] = value
    end

    parser.on('--env ENV', 'Run against a specific environment') do |value|
      options[:env] = value
    end
  end

end
