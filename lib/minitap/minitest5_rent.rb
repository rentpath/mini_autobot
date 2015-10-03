require 'minitap'

module Minitest

  ##
  # Base class for TapY and TapJ runners.
  #
  class Minitap

    attr_accessor :all_results

    def tapout_before_case(test_case)
      all_results << 'results123'
      Thread.current['all_results'] = all_results
      doc = {
          'type'    => 'case',
          'subtype' => '',
          'label'   => "#{test_case}",
          'level'   => 0
      }
      return doc
    end

  end

end
