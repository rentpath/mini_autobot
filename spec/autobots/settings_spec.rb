RSpec.describe Autobots::Settings do

  describe '#connector' do
    context 'by default' do
      subject { described_class.new.connector }
      it { is_expected.to eql('firefox') }
    end

    let(:settings) { described_class.new }
    it 'can be overridden and strifies' do
      settings.merge!(connector: :firefox)
      expect(settings.connector).to eql('firefox')
    end
  end

  describe '#env' do
    context 'by default' do
      subject { described_class.new.env }
      it { is_expected.to eql('rent_qa') }
    end

    let(:settings) { described_class.new }
    it 'can be overridden and stringifies' do
      settings.merge!(env: :dev)
      expect(settings.env).to eql('dev')
    end
  end

  describe '#tags' do
    context 'by default' do
      subject { described_class.new.tags }
      it { is_expected.to be_empty }
    end

    let(:settings) { described_class.new }
    it 'can be overridden' do
      settings.merge!(tags: [:test])
      expect(settings.tags).to eql([:test])
    end

    it 'can be appended' do
      settings.tags << :test
      expect(settings.tags).to eql([:test])
    end
  end

end
