require_relative '../spec_helper'
require_relative '../../lib/journey_walker'
require_relative '../../lib/journey_walker/journey_error'
require 'json'

#
# The config loaded here is of the form
#
# step1 --> step2
#
# The single transition between step one and two is based on a call to the multiply method of a JourneyWalkerTests
# class instance returning six.  The two parameters to the call are a fixed value: "2", and a call to the fetch_number
# method of the JourneyWalkerTests class.  In essence
#
# JourneyWalkerTests.new.multiply(2, JourneyWalkerTests.new.fetch_number(3))
#
describe JourneyWalker::Journey do
  let(:config) do
    JSON.parse(File.read('spec/journey_walker/config/hierarchical_data_source.json'), symbolize_names: true)
  end
  let(:journey) { described_class.new(config) }

  it 'should return step2 based on multiply and fetch number methods' do
    current_step = journey.start
    current_step = journey.perform_action(current_step, 'proceed')
    expect(current_step.name).to eq('step2')
  end
end
