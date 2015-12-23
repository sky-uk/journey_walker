require_relative '../../lib/journey_walker/journey'
require_relative '../../lib/journey_walker/journey_error'
require 'json'

#
# The basic config loaded here is of the form step1->step2->step1->step2 etc.
#
describe Journey do
  let(:config) { JSON.parse(File.read('spec/journey_walker/config/basic_config.json'), symbolize_names: true) }
  let(:journey) { Journey.new(config) }

  it 'should return the initial step on start' do
    initial_step = journey.start
    expect(initial_step.name).to eq('step1')
  end

  it 'should return next step on action' do
    current_step = journey.start
    current_step = journey.perform_action(current_step, 'proceed')
    expect(current_step.name).to eq('step2')
    current_step = journey.perform_action(current_step, 'restart')
    expect(current_step.name).to eq('step1')
    current_step = journey.perform_action(current_step, 'check')
    expect(current_step.name).to eq('step3')
  end

  it 'should throw an exception for an unknown action' do
    current_step = journey.start
    expect { journey.perform_action(current_step, 'unknown_action') }
      .to raise_error(JourneyError, /(unknown_action.*step1|step1.*unknown_action)/i)
  end

  it 'should throw an exception when multiple actions are valid' do
    current_step = journey.start
    expect { journey.perform_action(current_step, 'secondary_proceed') }
      .to raise_error(JourneyError, /(secondary_proceed.*too many|too many.*secondary_proceed)/i)
  end
end
