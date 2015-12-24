require 'json'
require_relative '../../lib/journey_walker'

describe JourneyWalker::Journey do
  let(:invalid_config) { JSON.parse(File.read('spec/journey_walker/config/installer.json'), symbolize_names: true) }

  it 'should not accept data switch without source' do
    invalid_config[:transitions][2][:data_switches][0].reject! { |key, _value| key == :source_call }
    expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                  /no source call is defined for data switch/i)
  end

  it 'should not accept data switch without value' do
    invalid_config[:transitions][2][:data_switches][0].reject! { |key, _value| key == :value }
    expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                  /no value is defined for data switch/i)
  end

  it 'should not accept data switch with unknown data source' do
    invalid_config[:transitions][2][:data_switches][0][:source_call][:source] = 'some source'
    expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                  /unknown data source "some source"/i)
  end
end
