module MiniAutobot

  # An object that holds runtime settings.
  #
  # Furthermore, Minitest doesn't provide any good way of passing a hash of
  # options to each test.
  #
  # TODO: We're importing ActiveSupport's extensions to Hash, which means that
  # we'll be amending the way Hash objects work; once AS updates themselves to
  # ruby 2.0 refinements, let's move towards that.
  class Settings

    def initialize
      @hsh = {}
    end

    def inspect
      settings = self.class.public_instance_methods(false).sort.map(&:inspect).join(', ')
      "#<MiniAutobot::Settings #{settings}>"
    end

    def auto_finalize?
      hsh.fetch(:auto_finalize, true)
    end

    def connector
      hsh.fetch(:connector, :firefox).to_s
    end

    def env
      # add a gitignored env file which stores a default env
      # pass the default env in as default
      hsh.fetch(:env, :rent_qa).to_s
    end

    def io
      hsh[:io]
    end

    def merge!(other)
      hsh.merge!(other.symbolize_keys)
      self
    end

    def parallel
      if hsh[:parallel] == 0
        return nil
      else
        hsh.fetch(:parallel).to_i
      end
    end

    def raw_arguments
      hsh.fetch(:args, nil).to_s
    end

    def reuse_driver?
      hsh.fetch(:reuse_driver, false)
    end

    def seed
      hsh.fetch(:seed, nil).to_i
    end

    def tags
      hsh[:tags] ||= []
    end

    def verbose?
      verbosity_level > 0
    end

    def verbosity_level
      hsh.fetch(:verbosity_level, 0).to_i
    end

    private
    attr_reader :hsh

  end

end
