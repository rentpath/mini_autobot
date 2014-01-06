
require 'pathname'

module Autobots #:nodoc:

  autoload :Connector, 'autobots/connector'
  autoload :PageObjects, 'autobots/page_objects'
  autoload :Settings, 'autobots/settings'
  autoload :Utils, 'autobots/utils'

  def self.root
    @@__root__ ||= Pathname.new(File.realpath(File.join(File.dirname(__FILE__), '..')))
  end

end

