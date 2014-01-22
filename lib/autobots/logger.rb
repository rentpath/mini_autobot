
module Autobots

  class Logger < ActiveSupport::Logger

    def initialize(file, *args)
      file = File.open(Autobots.root.join('logs', file), File::WRONLY | File::APPEND | File::CREAT) unless file.respond_to?(:write)
      super(file, *args)
    end

  end

end
