module Autobots
  class Runner

    def self.run!(args)
      exit_code = Minitest.run(args)
      Kernel.exit(exit_code || false)
    end

  end
end
