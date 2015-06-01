module Autobots
  module Utils
    module MyRentHelper
      include Autobots::Utils::Castable

      SUBMARKET_NM = 'Yakutat, AK'
      USER = { :email => 'myrent_autotester@test.com', :password => 'test' }
      LISTING_NUM = 1
      LOAD_MORE_THRESHOLD = 20
      MAX_SEARCHES = 10
      ## As we add page objects beyond SRP/PDP, we can test filter
      ## persistence more thoroughly. Currently only works for views. [~jacord]
      FILTER_PERSISTENCE_ACTIONS = [:report_your_lease!,:moving_center!]
      ## there are ten of these, which is important for testing the behavior
      ## of the activity count the search filter. A ZIP code search must be
      ## done to cover MA.
      SEARCH_LOCATIONS = 
        ['90404', 'Boston, MA', 'Phoenix, AZ', 'Manhattan, NY', 
         'Seattle, WA', 'Chicago, IL', 'Miami, FL', 'Houston, TX', 
         'San Francisco, CA', 'Baltimore, MD']

      #Users


      #Properties
      GRAND_AT_PARKVIEW = { :listingseopath => 'alaska/yakutat-condos/the-grand-at-parkview-4-100032535', :submarket => 'Yakutat, AK' }
      EGG_PROPERTY_THREE = { :listingseopath => 'alaska/yakutat-apartments/egg-property-three-4-100032676', :submarket => 'Yakutat, AK' }
      ASHLEY_PARK = { :listingseopath => 'alaska/yakutat-apartments/ashley-park-retirement-community-55-restricted-4-100032447', :submarket => 'Yakutat, AK' }
      DPS_PROPERTY_ONE = { :listingseopath => 'alaska/yakutat-apartments/dps-property-one-4-100032425', :submarket => 'Yakutat, AK' }
      EGG_PROPERTY_ONE = { :listingseopath => 'alaska/yakutat-apartments/egg-property-one-4-100032674', :submarket => 'Yakutat, AK' }
      PALAZZO_VILLAGE = { :listingseopath => 'alaska/yakutat-apartments/the-palazzo-village-4-100032601', :submarket => 'Yakutat, AK' }
      TEST_YAKU = { :listingseopath => 'alaska/yakutat-apartments/test-yaku-4-62591819', :submarket => 'Yakutat, AK' }
      EGG_PROPERTY_TWO = { :listingseopath => 'alaska/yakutat-apartments/egg-property-two-4-100032677', :submarket => 'Yakutat, AK' }
      WEB_PROPERTY_THREE = { :listingseopath => 'alaska/yakutat-apartments/web-property-three-4-100032536', :submarket => 'Yakutat, AK' }
      MISSION_PARK = { :listingseopath => 'california/gilroy-apartments/mission-park-4-100050849', :submarket => 'Gilroy, CA' }
      PARKVIEW_ESTATES = { :listingseopath => 'minnesota/coon-rapids-apartments/parkview-estates-4-441951', :submarket => 'Coon Rapids, MN' }
      TEST_YAKUTAT_H = { :listingseopath => 'minnesota/hopkins-apartments/test-yakutat-h-4-62657813', :submarket => 'm, MN' }
      OCEAN_HOUSE_ON_PROSPECT = { :listingseopath => 'california/la-jolla-apartments/ocean-house-on-prospect-4-61715856', :submarket => 'La Jolla, CA' }
      BAINBRIDGE_SHADY_GROVE = { :listingseopath => 'maryland/derwood-apartments/bainbridge-shady-grove-4-100051598', :submarket => 'Derwood, MD' }
      AXIS_BRANDON = { :listingseopath => 'florida/tampa-apartments/axis-brandon-4-100050842', :submarket => 'Tampa, FL' }
      GARFIELD_COMMONS = { :listingseopath => 'michigan/clinton-township-apartments/garfield-commons-apartment-homes-4-100012054', :submarket => 'Clinton Township, MI' }
      JEAN_RIVARD = { :listingseopath => 'michigan/detroit-apartments/jean-rivard-4-100025217', :submarket => 'Detroit, MI' }
      KENDALLWOOD = { :listingseopath => 'michigan/farmington-apartments/kendallwood-4-100024005', :submarket => 'Farmington, MI' }
      TEST_YAKU_1 = { :listingseopath => 'south-dakota/redfield-apartments/test-yaku1-4-62591818', :submarket => 'Redfield, SD' }
      YAKUTAT_PROPS = [GRAND_AT_PARKVIEW, EGG_PROPERTY_THREE, ASHLEY_PARK, DPS_PROPERTY_ONE, EGG_PROPERTY_ONE,
                        PALAZZO_VILLAGE, TEST_YAKU, EGG_PROPERTY_TWO, WEB_PROPERTY_THREE, MISSION_PARK, PARKVIEW_ESTATES,
                        TEST_YAKUTAT_H, OCEAN_HOUSE_ON_PROSPECT, BAINBRIDGE_SHADY_GROVE, AXIS_BRANDON, GARFIELD_COMMONS,
                        JEAN_RIVARD, KENDALLWOOD, TEST_YAKU_1]

      def new_account_setup()
        # Create username
        @username = generate_test_email

        # Register as a new Renter
        registration_overlay = @hp.click_signin_link!.click_create_account_link!
        password_overlay = registration_overlay.hp_reg(@username)
        loggedin_hp = password_overlay.hp_new_pwd
        assert_match loggedin_hp.loggedin_username, @username

        # click on MyRent, goto My Rent page
        @mrp = loggedin_hp.my_rent!
      end

      def new_test_account()
        # placeholder
      end

      def contact_property(property)
        @pdp = go_to_pdp!(property)
        prop_name = @pdp.property_name
        hotlead_confirm = @pdp.li_hl_send!('test')
        @pdp = hotlead_confirm.close_confirmation_box!(:property_details)
        prop_name
      end

      def contact_properties(properties)
        prop_names = []
        properties.each do |property|
          contact_property(property)
          prop_names.push(property.name)
        end
        @mrp = @pdp.my_rent!
        prop_names
      end

      def view_properties(properties)
        self.logger.debug "view_properties"
        properties.each do |property|
          @pdp = go_to_pdp!(property)
        end
        @mrp = @pdp.my_rent!
      end

      def generate_list_of_properties(num_props, locations)
        self.logger.debug "generate_list_of_properties"
        properties = [] # properties processed
        @srp = @mrp.default_search! # go to srp
        ## run until we've processed the desired number of properties or exhausted locations
        while properties.length < num_props && locations.length > 0 do 
          begin
            self.logger.debug "searching next location: '#{locations.last}'"
            @location = locations.pop
            @srp = @srp.search!(@location) # do a search
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
          names = nonfeatured.map { |l| l.property_name}
          names = names.uniq
          prop_list = names.zip(urls).to_h
          # process as many properties as you can from these search results
          prop_list.each do |name, url|
            new_prop = Rent_Property.new(name, url, @location)
            # We only want to log unique property page views
            properties.push(new_prop)
            break if properties.length == num_props    # stop if we have the desired number of properties
          end
        end
        @mrp = @srp.my_rent!                   # go back to My Rent
        return properties               # unused places, used names
      end

      def go_to_pdp!(property)
        @mrp.go_to_subpage!(property.url, :property_details)
      end

      def save_property(property)
        @pdp = go_to_pdp!(property)
        prop_name = @pdp.property_name
        @pdp.add_favorite
        prop_name
      end

      def save_properties(properties)
        prop_names = []
        properties.each do |property|
          save_property(property)
          prop_names.push(property.name)
        end
        @pdp.my_rent!
        prop_names
      end

      class Rent_Property

        attr_reader :name
        attr_reader :url
        attr_reader :location

        def initialize(name, url, location)
          @name = name
          @url = url
          @location = location
        end

      end
    end #MyRentHelper
  end #Utils
end #Autobots
