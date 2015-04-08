module Autobots
  module Utils
    module MyRentHelper
      include Autobots::Utils::Castable

      SUBMARKET_NM = 'Yakutat, AK'
      USER = { :email => 'myrent_autotester@rent.com', :password => 'test' }
      LISTING_NUM = 1
      LOAD_MORE_THRESHOLD = 20
      MAX_SEARCHES = 10
      ## As we add page objects beyond SRP/PDP/PSP, we can test filter
      ## persistence more thoroughly. Currently only works for views. [~jacord]
      FILTER_PERSISTENCE_ACTIONS = [:report_your_lease!,:moving_center!]
      ## there are ten of these, which is important for testing the behavior
      ## of the activity count the search filter. A ZIP code search must be
      ## done to cover MA.
      SEARCH_LOCATIONS = 
        ['90404', 'Boston, MA', 'Phoenix, AZ', 'Manhattan, NY', 
         'Seattle, WA', 'Chicago, IL', 'Miami, FL', 'Houston, TX', 
         'San Francisco, CA', 'Baltimore, MD']

      def new_account_setup()
        @srp = @hp.search(SUBMARKET_NM)

        # Create username
        @username = generate_random_email

        # View first property listing with reward card on the SRP
        loggedout_pdp = @srp.go_to_listing!(LISTING_NUM)

        # Register as a new Renter on LO PDP
        registration_overlay = loggedout_pdp.click_reg_link!
        loggedin_pdp = registration_overlay.reg(@username, 'property_details')
        password_overlay = loggedin_pdp.create_password
        password_overlay.pdp_new_pwd
        assert_match @srp.loggedin_username, @username

        search = loggedin_pdp.default_search!
       # click on MyRent, goto My Rent page
        @mrp = search.my_rent!

      end

      def do_property_actions(n, locations, callback)
        self.logger.debug "do_property_actions_new"
        names = [] # properties processed
        page = @mrp
        ## run until we've processed n properties or exhausted locations
        while names.length < n && locations.length > 0 do 
          begin
            @srp = page.default_search!        # go to srp
            self.logger.debug "searching next location: '#{locations.last}'"
            puts "searching next location: '#{locations.last}'"
            @srp = @srp.search!(locations.pop) # do a search
          rescue
            self.logger.debug "problem during search; trying again"
            puts "problem during search; trying again"
            next
          end

          # Find and visit the first non-featured listing on the page. We
          # ignore featured listings because they rotate randomly [~jacord]
          nonfeatured = @srp.listings

          puts nonfeatured[0].url

          ## if there are no non-featured results, skip this location.
          if nonfeatured.nil? || nonfeatured.empty? 
            self.logger.debug "no listings" 
            next 
          end

          urls = nonfeatured.map { |l| l.url }
          # process as many properties as you can from these search results
          urls.each do |url|
            self.logger.debug("going to '#{url}");
            puts "going to #{url}"
            @driver.navigate.to(url)
            sleep 5
            page = Autobots::PageObjects::Base.cast(@driver,:property_details)
            begin
              if callback.call(page)           # do action
                sleep 2
                names.push page.property_name  # save name
              else
                self.logger.debug "PDP action failed: property name will not be recorded"
              end
            rescue => error
              self.logger.debug "PDP action raised: #{error.inspect}\n\nsearching elsewhere"
              break
            end
            break if names.length == n         # stop if we've done N things
          end
        end
        @mrp = page.my_rent!                   # go back to My Rent
        return locations, names                # unused places, used names
      end

      ## mixin some stuff so we don't have to put in the setup block

      ## Callbacks for activity across pages. Relocated to DRY up the code.
      ## Relocated again for further cleanup
      def hotlead_callback
        @hotlead_callback ||= lambda do |pdp|
          begin 
            puts "starting"
            hotlead_confirm = pdp.hl_send(@username)
            puts "made it back"
            sleep 5
            hotlead_confirm.close_confirmation_box
          rescue => error 
            self.logger.warn ":hl_send raised:\n#{error.inspect}"
          end
          return true;
        end
      end

      def view_callback
        @view_callback ||= lambda do |pdp| 
          return pdp.ensure_register 
        end
      end

      def save_property_callback
        @save_property_callback ||= lambda do |pdp|
          pdp.add_favorite 
          return true
        end
      end

      def view_properties(n, locations)
        self.logger.debug "view_properties"
        names = [] # properties processed
        page = @mrp
        ## run until we've processed n properties or exhausted locations
        while names.length < n && locations.length > 0 do 
          begin
            @srp = page.default_search!        # go to srp
            self.logger.debug "searching next location: '#{locations.last}'"
            @srp = @srp.search!(locations.pop) # do a search
          rescue
            self.logger.debug "problem during search; trying again"
            next
          end

          # Find and visit the first non-featured listing on the page. We
          # ignore featured listings because they rotate randomly [~jacord]
          nonfeatured = @srp.listings

          ## if there are no non-featured results, skip this location.
          if nonfeatured.nil? || nonfeatured.empty? 
            self.logger.debug "no listings" 
            next 
          end

          urls = nonfeatured.map { |l| l.url }
          urls = urls.uniq
          # process as many properties as you can from these search results
          urls.each do |url|
            @driver.execute_script("window.stop()")
            #url.slice!('qateam:wap88@')
            self.logger.debug("going to '#{url}");
            puts "going to #{url}"
            @driver.navigate.to(url)
            # Using sleep as placeholder until we find something reliable to wait for on the page
            sleep 5
            @driver.execute_script("window.stop()")
            page = Autobots::PageObjects::Base.cast(@driver,:property_details)
            # We only want to log unique property page views
            if !names.include?(page.property_name)
              names.push page.property_name
            end
            puts names.length
            break if names.length == n         # stop if we've done N things
          end
        end
        @mrp = page.my_rent!                   # go back to My Rent
        return locations, names                # unused places, used names
      end
    end #MyRentHelper
  end #Utils
end #Autobots
