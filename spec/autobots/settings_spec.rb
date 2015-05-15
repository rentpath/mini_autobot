describe Autobots::Settings do

  describe '#env' do
    subject { described_class.new.env }
    it { is_expected.to eql('qa') }
  end

end
