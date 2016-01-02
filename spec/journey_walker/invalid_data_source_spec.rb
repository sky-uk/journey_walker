require_relative '../spec_helper'
require 'json'

describe JourneyWalker::Journey do
  let(:invalid_config) { JSON.parse(File.read('spec/journey_walker/config/installer.json'), symbolize_names: true) }

  it 'should not accept condition without source' do
    invalid_config[:data_sources][0][:type] = 'unknown_type'
    expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError)
  end

  it 'should validate using the data source' do
    invalid_config[:data_sources][0][:parameters] = []
    expect { described_class.new(invalid_config) }.to raise_error(JourneyWalker::Config::InvalidConfigError)
  end
end
