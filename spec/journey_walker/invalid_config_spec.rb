require 'json'
require_relative '../../lib/journey_walker/journey'

describe JourneyWalker::Journey do
  let(:invalid_config) { JSON.parse(File.read('spec/journey_walker/config/basic_config.json'), symbolize_names: true) }

  context 'transitions' do
    it 'should not accept journey with no transitions' do
      invalid_config.reject! { |key, _value| key == :transitions }
      expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                    /no transitions are defined in journey/i)
    end

    it 'should not accept journey with empty transitions' do
      invalid_config[:transitions].clear
      expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                    /no transitions are defined in journey/i)
    end

    it 'should not accept journey with no initial transition' do
      invalid_config[:transitions].delete_if { |value| value[:action] == 'start' }
      expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                    /no initial transition defined/i)
    end

    it 'should not accept initial transition with "from:"' do
      invalid_config[:transitions].find { |value| value[:action] == 'start' }[:from] = 'somewhere'
      expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                    /no initial transition defined/i)
    end

    it 'should not accept transition with no "to:"' do
      invalid_config[:transitions].find { |value| value.key?(:from) }.reject! { |key, _value| key == :to }
      expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                    /no to: defined on transition/i)
    end

    it 'should not accept transition with no action' do
      invalid_config[:transitions].first.reject! { |key, _value| key == :action }
      expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                    /no action defined on transition/i)
    end
  end
end
