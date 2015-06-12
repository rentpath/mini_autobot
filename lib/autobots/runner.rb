module Autobots
  class Runner

    @after_hooks = []

    def self.after_run(&blk)
      @after_hooks << blk
    end

    def self.run!(args)
      exit_code = Minitest.run(args)
      @after_hooks.reverse_each(&:call)
      Kernel.exit(exit_code || false)
    end

  end
end
