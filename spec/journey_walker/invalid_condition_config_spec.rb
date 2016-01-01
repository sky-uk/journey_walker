require 'json'
require_relative '../../lib/journey_walker'

describe JourneyWalker::Journey do
  let(:invalid_config) { JSON.parse(File.read('spec/journey_walker/config/installer.json'), symbolize_names: true) }

  it 'should not accept condition without source' do
    invalid_config[:transitions][2][:conditions][0].reject! { |key, _value| key == :source_call }
    expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError)
  end

  it 'should not accept condition without value' do
    invalid_config[:transitions][2][:conditions][0].reject! { |key, _value| key == :value }
    expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError)
  end

  it 'should not accept condition with unknown data source' do
    invalid_config[:transitions][2][:conditions][0][:source_call][:source] = 'some source'
    expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError,
                                                                  /unknown data source "some source"/i)
  end
end
