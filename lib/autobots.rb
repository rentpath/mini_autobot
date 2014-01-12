
require 'pathname'

# The base module for everything Autobots and is the container for other
# modules and classes in the hierarchy:
#
# * `Connector` provides support for drivers and connector profiles;
# * `Emails` introduces email-specific drivers for Autobots;
# * `PageObjects` provides a hierarchy of page objects, page modules, widgets,
#   and overlays;
# * `Settings` provides support for internal Autobots settings; and
# * `Utils` provides an overarching module for miscellaneous helper modules.
#
# When new, modules or classes are added, an `autoload` clause must be added
# into this top-level module so that requires are taken care of automatically.
module Autobots

  autoload :Connector, 'autobots/connector'
  autoload :PageObjects, 'autobots/page_objects'
  autoload :Settings, 'autobots/settings'
  autoload :Utils, 'autobots/utils'

  autoload :Emails, 'autobots/emails'

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

