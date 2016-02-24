require_relative '../spec_helper'
require_relative '../../lib/journey_walker/journey_error'
require 'json'

#
# The config loaded here is of the form
#
# state1 --> state2
#
# The single transition between state one and two is based on a call to the multiply method of a JourneyWalkerTests
# class instance returning six.  The two parameters to the call are a fixed value: "2", and a call to the fetch_number
# method of the JourneyWalkerTests class.  In essence
#
# JourneyWalkerTests.new.multiply(2, JourneyWalkerTests.new.fetch_number(3))
#
describe JourneyWalker::Journey do
  let(:config) do
    JSON.parse(File.read('spec/journey_walker/config/hierarchical_data_source.json'), symbolize_names: true)
  end
  let(:services) { { os_service: double } }
  let(:journey) { described_class.new(config, services) }

  it 'should return state2 based on multiply and fetch number methods' do
    current_state = journey.start
    current_state = journey.perform_action(current_state[:name], 'proceed')
    expect(current_state[:name]).to eq('state2')
  end

  context 'journey with injected services' do
    it 'call service method' do
      allow(services[:os_service]).to receive(:service_method).and_return('service_value')
      current_state = journey.start
      current_state = journey.perform_action(current_state[:name], 'service_proceed')
      expect(current_state[:name]).to eq('state3')
    end
  end
end
