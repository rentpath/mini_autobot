
module Autobots

  # A connector provides a thin layer that combines configuration files and
  # access to the WebDriver. It's a thin layer in that, other than #initialize,
  # it is a drop-in replacement for WebDriver calls.
  #
  # For example, if you usually access a method as `@driver.find_element`, you
  # can still access them as the same method under `@connector.find_element`.
  class Connector

    # Simple configuration container for all profiles. Struct is not used here
    # because it contaminates the class with Enumerable methods, which will
    # cause #method_missing in Connector to get confused.
    class Config
      attr_accessor :connector, :env

      def ==(other)
        self.class == other.class && self.connector == other.connector && self.env == other.env
      end

      alias_method :eql?, :==

      def hash
        @connector.hash ^ @env.hash
      end

      # Initialize a new configuration object. This object should never be
      # instantiated directly.
      #
      # @api private
      def initialize(connector, env)
        @connector, @env = connector, env
      end

    end

    class <<self
      protected
      attr_accessor :pool
    end

    def self.finalize!
      return unless self.pool
      self.pool.values.each do |connector|
        connector.finalize!
      end
      self.pool.clear
    end

    # Given a connector profile and an environment profile, this method will
    # instantiate a connector object with the correct WebDriver instance and
    # settings.
    #
    # @raise ArgumentError
    # @param connector [#to_s] the name of the connector profile to use.
    # @param env [#to_s] the name of the environment profile to use.
    # @return [Connector] an initialized connector object
    def self.get(connector, env)
      self.pool ||= {}

      # Ensure arguments are at least provided
      raise ArgumentError, "A connector must be provided" if connector.blank?
      raise ArgumentError, "An environment must be provided" if env.blank?

      # Find the connector profile and load it
      connector_cfg = self.load(Autobots.root.join('config', 'connectors'), connector)

      # Find the environment profile and load it
      env_cfg = self.load(Autobots.root.join('config', 'environments'), env)

      # Grab an existing instance, if once already exists, but make sure to
      # reset the driver first
      cfg = Config.new(connector_cfg, env_cfg)
      if self.pool.has_key?(cfg)
        return self.pool[cfg].tap(:reset!)
      end

      # Instantiate a connector, which will take care of instantiating the
      # WebDriver and configure its options
      self.pool[cfg] = Connector.new(cfg)
    end

    # Load profile from a specific path using the selector(s) specified.
    #
    # @raise ArgumentError
    # @param path [#to_path, #to_s] the path in which to find the profile
    # @param selector [String] semicolon-delimited selector set
    # @return [Hash] immutable configuration values
    def self.load(path, selector)
      overrides = selector.to_s.split(/:/)
      name      = overrides.shift
      filepath  = path.join("#{name}.yml")
      raise ArgumentError, "Cannot load profile #{name.inspect} because #{filepath.inspect} does not exist" unless filepath.exist?

      cfg = YAML.load(File.read(filepath))
      cfg = self.resolve(cfg, overrides)
      cfg.freeze
    end

    # Resolve a set of profile overrides.
    #
    # @param cfg [Hash] the configuration structure optionally containing a
    #   key of `:overrides`
    # @param overrides [Enumerable<String>]
    # @return [Hash] the resolved configuration
    def self.resolve(cfg, overrides)
      cfg = cfg.dup.with_indifferent_access

      if options = cfg.delete(:overrides)
        # Evaluate each override in turn, allowing each override to--well,
        # override--anything coming before it
        overrides.each do |override|
          if tree = options[override]
            cfg.deep_merge!(tree)
          end
        end
      end

      cfg
    end

    # Perform cleanup on the connector and driver.
    def finalize!
      @driver.quit
      true
    end

    # Initialize a new connector with a set of configuration files.
    #
    # @see Connector.get
    # @api private
    def initialize(config)
      @config = config

      # Load and configure the WebDriver, if necessary
      if concon = config.connector
        driver_config = { }
        driver = concon[:driver]
        raise ArgumentError, "Connector driver must not be empty" if driver.nil?

        # Handle hub-related options, like hub URLs (for remote execution)
        if hub = concon[:hub]
          driver_config[:url] = hub[:url]
        end

        # Handle driver-related timeouts
        if timeouts = concon[:timeouts]
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.timeout = timeouts[:driver]
          driver_config[:http_client] = client
        end

        # Handle archetypal capability lists
        if archetype = concon[:archetype]
          caps = Selenium::WebDriver::Remote::Capabilities.send(archetype)
          if caps_set = concon[:capabilities]
            caps.merge!(caps_set)
          end
          driver_config[:desired_capabilities] = caps
        end

        # Initialize the driver and declare explicit browser timeouts
        @driver = Selenium::WebDriver.for(driver.to_sym, driver_config)
        if timeouts = concon[:timeouts]
          @driver.manage.timeouts.implicit_wait  = timeouts[:implicit_wait]  if timeouts[:implicit_wait]
          @driver.manage.timeouts.page_load      = timeouts[:page_load]      if timeouts[:page_load]
          @driver.manage.timeouts.script_timeout = timeouts[:script_timeout] if timeouts[:script_timeout]
        end
      end
    end

    # Forward any other method call to the configuration container; if that
    # fails, forward it to the WebDriver. The WebDriver will take care of any
    # method resolution errors.
    #
    # @param name [#to_sym] symbol representing the method call
    # @param args [*Object] arguments to be passed along
    def method_missing(name, *args, &block)
      if @config.respond_to?(name)
        @config.send(name, *args, *block)
      else
        #puts "DRIVER->#{name}"
        @driver.send(name, *args, &block)
      end
    end

    # Resets the current session by deleting all cookies and clearing all
    # local and session storage.
    #
    # @return [Boolean]
    def reset!
      @driver.deleteAllCookies
      @driver.clearLocalStorage
      @driver.clearSessionStorage
      true
    end

    # Compose a URL from the provided +path+ and the environment profile. The 
    # latter contains things like the hostname, port, SSL settings.
    #
    # @param path [#to_s] the path to append after the root URL.
    # @return [URI] the composed URL.
    def url_for(path)
      root = @config.env[:root]
      raise ArgumentError, "The 'root' attribute is missing from the environment profile" unless root
      URI.join(root, path)
    end

  end
end

