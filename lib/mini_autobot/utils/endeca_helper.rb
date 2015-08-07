
module MiniAutobot
  module Utils

    # Page object-related helper methods.
    module EndecaHelper

      # Helper method to instantiate a new page object. This method should only
      # be used when first loading; subsequent page objects are automatically
      # instantiated by calling #cast on the page object.
      #
      # @param name [String, Symbol]
      # @return [PageObject::Base]
      def endeca(name)
        # Get the fully-qualified class name
        klass_name = "mini_autobot/database/endeca".camelize
        klass = begin
          klass_name.constantize
        rescue => exc
          msg = ""
          msg << "Cannot find page object '#{name}', "
          msg << "because could not load class '#{klass_name}' "
          msg << "with underlying error:\n  #{exc.class}: #{exc.message}\n"
          msg << exc.backtrace.map { |str| "    #{str}" }.join("\n")
          raise NameError, msg
          
        driver = MiniAutobot::Connector.get_default
        instance = klass.new(driver)
        
        Drawbridge.setup do |config|
          config.bridge_url = driver.env[:endeca][:url]
          config.bridge_path = driver.env[:endeca][:bridge]
          # e.g. ENDECA_DEBUG=true rackup
          config.endeca_debug = ENV.fetch('ENDECA_DEBUG') { false }
          # optional, default is 5
          config.timeout = 5
          # optional, default is to change ' into &#39; before JSON is parsed
          config.skip_single_quote_encoding = true
        end
        
        return instance
       end        
      end
     end
  end
end