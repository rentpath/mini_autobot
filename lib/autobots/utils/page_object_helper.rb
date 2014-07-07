
module Autobots
  module Utils

    # Page object-related helper methods.
    module PageObjectHelper

      # Helper method to instantiate a new page object. This method should only
      # be used when first loading; subsequent page objects are automatically
      # instantiated by calling #cast on the page object.
      # Pass optional parameter Driver, which can be initialized in test and will override the global driver here.
      #
      # @param name [String, Driver]
      # @return [PageObject::Base]
      def page(name, override_driver=nil)
        # Get the fully-qualified class name
        klass_name = "autobots/page_objects/#{name}".camelize
        klass = begin
          klass_name.constantize
        rescue => exc
          msg = ""
          msg << "Cannot find page object '#{name}', "
          msg << "because could not load class '#{klass_name}' "
          msg << "with underlying error:\n  #{exc.class}: #{exc.message}\n"
          msg << exc.backtrace.map { |str| "    #{str}" }.join("\n")
          raise NameError, msg
        end

        # Get a default connector
        @driver = Autobots::Connector.get_default if override_driver.nil?
        @driver = override_driver if !override_driver.nil?
        instance = klass.new(@driver)

        # Before visiting the page, do any pre-processing necessary, if any,
        # but only visit the page if the pre-processing succeeds
        if block_given?
          retval = yield instance
          instance.go! if retval
        else
          instance.go! if override_driver.nil?
        end

        # Return the instance as-is
        instance
      end

      # Local teardown for page objects. Any page objects that are loaded will
      # be finalized upon teardown.
      #
      # @return [void]
      def teardown
        set_sauce_session_name if connector_is_saucelabs && !@driver.nil?
        Autobots::Connector.finalize! if Autobots::Settings[:auto_finalize]
        super()
      end

      # update session name on saucelabs in teardown for every test
      def set_sauce_session_name
        # identify the user who runs the tests and grab user's access_key
        # where are we parsing info from run command to in the code?
        connector = Autobots::Settings[:connector] # eg. saucelabs:phu:win7_ie11
        overrides = connector.to_s.split(/:/)
        new_tags = overrides[2]+"_by_"+overrides[1]
        file_name = overrides.shift
        path = Autobots.root.join('config', 'connectors')
        filepath  = path.join("#{file_name}.yml")
        raise ArgumentError, "Cannot load profile #{file_name.inspect} because #{filepath.inspect} does not exist" unless filepath.exist?

        cfg = YAML.load(File.read(filepath))
        cfg = Connector.resolve(cfg, overrides)
        cfg.freeze
        username = cfg["hub"]["user"]
        access_key = cfg["hub"]["pass"]

        require 'json'
        session_id = @driver.session_id
        http_auth = "https://#{username}:#{access_key}@saucelabs.com/rest/v1/#{username}/jobs/#{session_id}"
        # to_json need to: require "active_support/core_ext", but will mess up the whole framework, require 'json' in this method solved it
        body = {"name" => name(), "tags" => [new_tags]}.to_json
        # RestClient need to: gem install rest-client, 
        # then to add it to library, add line "gem rest-client" to GemFile first, then do "bundle install"
        RestClient.put(http_auth, body, {:content_type => "application/json"})
      end
      
      def connector_is_saucelabs
        return true if Autobots::Settings[:connector].include?('saucelabs')
        return false
      end

      # Generic page object helper method to clear and send keys to a web element found by driver
      # @param [Element, String]
      def put_value(web_element, value)
        web_element.clear
        web_element.send_keys(value)
      end

      # Check if a web element exists on page or not, without wait
      # @param  eg. (:css, 'button.cancel') or (*BUTTON_GETSTARTED)
      # @return [boolean]
      def is_element_present(how, what)
        @driver.manage.timeouts.implicit_wait = 0
        result = @driver.find_elements(how, what).size() > 0
        if result
          result = @driver.find_element(how, what).displayed?
        end
        @driver.manage.timeouts.implicit_wait = 30
        return result
      end
    end

  end
end
