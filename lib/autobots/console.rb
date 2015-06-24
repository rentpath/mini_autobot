module Autobots
  class Console < TestCase

    def self.bootstrap!
      Autobots.settings.tags << [:__dummy__]
    end

    test :dummy, tags: [:focus, :__dummy__], serial: 'DUMMY' do
      assert_respond_to binding, :pry
      binding.pry
    end

  end
end
