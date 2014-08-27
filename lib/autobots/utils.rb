
module Autobots

  # Container for utility modules.
  module Utils

    autoload :AssertionHelper,     'autobots/utils/assertion_helper'
    autoload :Castable,            'autobots/utils/castable'
    autoload :DataGeneratorHelper, 'autobots/utils/data_generator_helper'
    autoload :DataObjectHelper,    'autobots/utils/data_object_helper'
    autoload :Loggable,            'autobots/utils/loggable'
    autoload :PageObjectHelper,    'autobots/utils/page_object_helper'
    autoload :BrowserHelper,       'autobots/utils/browser_helper'
    autoload :OverlayAndWidgetHelper,'autobots/utils/overlay_and_widget_helper'

  end
end

