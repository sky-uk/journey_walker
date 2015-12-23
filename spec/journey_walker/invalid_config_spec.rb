require 'json'
require_relative '../../lib/journey_walker/journey'

describe Journey do
  let(:invalid_config) { JSON.parse(File.read('spec/journey_walker/config/basic_config.json'), symbolize_names: true) }

  it 'should not accept journey with no transitions' do
    invalid_config.reject! { |key, _value| key == :transitions }
    expect { Journey.new(invalid_config) }.to raise_error(JourneymanInvalidConfigError,
                                                          /no transitions are defined in journey/i)
  end

  it 'should not accept journey with empty transitions' do
    invalid_config[:transitions].clear
    expect { Journey.new(invalid_config) }.to raise_error(JourneymanInvalidConfigError,
                                                          /no transitions are defined in journey/i)
  end

  it 'should not accept journey with no initial transition' do
    invalid_config[:transitions].delete_if { |value| value[:action] == 'start' }
    expect { Journey.new(invalid_config) }.to raise_error(JourneymanInvalidConfigError,
                                                          /no initial transition defined/i)
  end

  it 'should not accept initial transition with "from:"' do
    invalid_config[:transitions].find { |value| value[:action] == 'start' }[:from] = 'somewhere'
    expect { Journey.new(invalid_config) }.to raise_error(JourneymanInvalidConfigError,
                                                          /no initial transition defined/i)
  end

  it 'should not accept transition with no "to:"' do
    invalid_config[:transitions].find { |value| value.key?(:from) }.reject! { |key, _value| key == :to }
    expect { Journey.new(invalid_config) }.to raise_error(JourneymanInvalidConfigError,
                                                          /no to: defined on transition/i)
  end

  it 'should not accept transition with no action' do
    invalid_config[:transitions].first.reject! { |key, _value| key == :action }
    expect { Journey.new(invalid_config) }.to raise_error(JourneymanInvalidConfigError,
                                                          /no action defined on transition/i)
  end
end
