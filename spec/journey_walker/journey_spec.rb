require_relative '../spec_helper'
require_relative '../../lib/journey_walker/journey_error'
require 'json'

#
# The basic config loaded here is of the form state1->state2->state1->state2 etc.
#
describe JourneyWalker::Journey do
  let(:config) { JSON.parse(File.read('spec/journey_walker/config/basic_config.json'), symbolize_names: true) }
  let(:journey) { described_class.new(config) }

  it 'should return the initial state on start' do
    initial_state = journey.start
    expect(initial_state[:name]).to eq('state1')
  end

  it 'should return next state on action' do
    current_state = journey.start
    current_state = journey.perform_action(current_state[:name], 'proceed')
    expect(current_state[:name]).to eq('state2')
    current_state = journey.perform_action(current_state[:name], 'restart')
    expect(current_state[:name]).to eq('state1')
    current_state = journey.perform_action(current_state[:name], 'check')
    expect(current_state[:name]).to eq('state3')
  end

  it 'should get data associated with state' do
    current_state = journey.start
    expect(current_state[:data]).to eq([{ name: 'data_val', value: true }])
  end

  it 'should throw an exception for an unknown action' do
    current_state = journey.start
    expect { journey.perform_action(current_state[:name], 'unknown_action') }
      .to raise_error(JourneyWalker::JourneyError, /(unknown_action.*state1|state1.*unknown_action)/i)
  end

  it 'should throw an exception when multiple actions with the same name are valid' do
    current_state = journey.start
    expect { journey.perform_action(current_state[:name], 'secondary_proceed') }
      .to raise_error(JourneyWalker::JourneyError, /(secondary_proceed.*too many|too many.*secondary_proceed)/i)
  end

  it 'should return allowed actions for current step' do
    current_state = journey.start
    actions = journey.allowed_actions(current_state[:name])
    expect(actions.length).to eq(3)
    expect(actions).to include({ name: 'check', data: nil },
                               { name: 'proceed', data: nil },
                               name: 'secondary_proceed', data: { friendly_name: 'Secondary Proceed' })
  end
end
