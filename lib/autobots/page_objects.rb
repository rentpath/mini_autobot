module Autobots

  # This is the overarching module that contains page objects, modules, and
  # widgets.
  #
  # When new modules or classes are added, an `autoload` clause must be added
  # into this module so that requires are taken care of automatically.
  module PageObjects

    # Exception to capture validation problems when instantiating a new page
    # object. The message contains the page object being instantiated as well
    # as the original, underlying error message if any.
    class InvalidePageState < Exception; end

  end

end

# Major classes and modules
require_relative 'page_objects/base'
require_relative 'page_objects/overlay'
require_relative 'page_objects/widgets'

# Page modules and components
require_relative 'page_objects/common'
require_relative 'page_objects/common_mobile'

# Page objects
require_relative 'page_objects/home'
require_relative 'page_objects/search'
require_relative 'page_objects/property_details'
require_relative 'page_objects/my_rent'
require_relative 'page_objects/mbs'
require_relative 'page_objects/search_by'
require_relative 'page_objects/moving_center1'
require_relative 'page_objects/site_map'
require_relative 'page_objects/fb_signin'
require_relative 'page_objects/gplus_signin'
require_relative 'page_objects/city_guide'
require_relative 'page_objects/moving_center2'

# Mobile-specific page objects
require_relative 'page_objects/home_mobile'
require_relative 'page_objects/search_mobile'
