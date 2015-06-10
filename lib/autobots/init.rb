# The base module for everything Autobots and is the container for other
# modules and classes in the hierarchy:
#
# * `Connector` provides support for drivers and connector profiles;
# * `Emails` introduces email-specific drivers for Autobots;
# * `PageObjects` provides a hierarchy of page objects, page modules, widgets,
#   and overlays;
# * `Settings` provides support for internal Autobots settings; and
# * `Utils` provides an overarching module for miscellaneous helper modules.
module Autobots

  def self.logger
    @@logger ||= Autobots::Logger.new($stdout)
  end

  def self.logger=(value)
    @@logger = value
  end

  def self.settings
    @@settings ||= Settings.new
  end

  def self.settings=(options)
    self.settings.merge!(options)
  end

  # Magical method that automatically figures out the root directory of the
  # automation repository, which is the directory that contains `lib` and
  # `config` subdirectories.
  #
  # The return value of this method can be safely used to refer to other
  # directories, for example:
  #
  #   File.read(Autobots.root.join('config', 'data.yml'))
  #
  # will return the contents of `config/data.yml`.
  #
  # @return [Pathname] A reference to the root directory, ready to be used
  #         in directory and file path calculations.
  def self.root
    @@__root__ ||= Pathname.new(File.realpath(File.join(File.dirname(__FILE__), '..')))
  end

end

require_relative 'logger'
require_relative 'utils'

require_relative 'connector'
require_relative 'dao'
require_relative 'page_objects'
require_relative 'parallel'
require_relative 'settings'

require_relative 'emails'

require_relative 'test_case'
require_relative 'console'

require_relative 'test_cases'
