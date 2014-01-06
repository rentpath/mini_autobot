
module Autobots

  # A connector provides a thin layer that combines configuration files and
  # access to the WebDriver. It's a thin layer in that, other than #initialize,
  # it is a drop-in replacement for WebDriver calls.
  #
  # For example, if you usually access a method as +@driver.find_element+, you
  # can still access them as the same method under +@connector.find_element+.
  class Connector

    # Simple configuration container for all profiles. +Struct+ is not used here
    # because it contaminates the class with +Enumerable+ methods, which will
    # cause +method_missing+ in +Connector+ to get confused.
    class Config
      attr_reader :connector, :env

      def initialize(connector, env)
        @connector, @env = connector, env
      end

    end

    # Given a connector profile and an environment profile, this method will
    # instantiate a connector object with the correct WebDriver instance and
    # settings.
    def self.get(connector, env)
      # Ensure arguments are at least provided
      raise ArgumentError, "A connector must be provided" if connector.blank?
      raise ArgumentError, "An environment must be provided" if env.blank?

      # Find the connector profile and load it
      connector_path = Autobots.root.join('config', 'connectors', "#{connector}.yml")
      raise ArgumentError, "Cannot load connector profile '#{connector}' because '#{connector_path}' does not exist" unless connector_path.exist?
      connector_cfg = YAML.load(File.read(connector_path))
      connector_cfg.deep_symbolize_keys!

      # Find the environment profile and load it
      env_path = Autobots.root.join('config', 'environments', "#{env}.yml")
      raise ArgumentError, "Cannot load environment profile '#{env}' because '#{env_path}' does not exist" unless env_path.exist?
      env_cfg = YAML.load(File.read(env_path))
      env_cfg.deep_symbolize_keys!

      # Instantiate a connector, which will take care of instantiating the
      # WebDriver and configure its options
      Connector.new(Config.new(connector_cfg, env_cfg))
    end

    # Initialize a new connector with a set of configuration files.
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
    def method_missing(name, *args, &block)
      if @config.respond_to?(name)
        @config.send(name, *args, *block)
      else
        @driver.send(name, *args, &block)
      end
    end

    # Compose a URL from the provided +path+ and the environment profile. The 
    # latter contains things like the hostname, port, SSL settings.
    def url_for(path)
      root = @config.env[:root]
      raise ArgumentError, "The 'root' attribute is missing from the environment profile" unless root
      URI.join(root, path)
    end

  end
end

