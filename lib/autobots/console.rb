
module Autobots

  class Console < TestCase

    def self.bootstrap!
      exit self.new(:test_dummy).test_dummy
    end

    test :dummy, tags: [:__dummy__], serial: 'DUMMY' do
      assert_respond_to binding, :pry
      binding.pry
    end

  end

end
