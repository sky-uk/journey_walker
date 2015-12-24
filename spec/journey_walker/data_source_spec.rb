require_relative '../spec_helper'
require_relative '../../lib/journey_walker'
require_relative '../../lib/journey_walker/journey_error'
require 'json'

#
# The config loaded here is of the form
#
# intro ->linux apt-get    -> finish
#       \->linux rpm      /
#        \->windows      /
#
# i.e. an initial page followed by a page based on OS and package manager followed by a final page
#
describe JourneyWalker::Journey do
  let(:config) { JSON.parse(File.read('spec/journey_walker/config/installer.json'), symbolize_names: true) }
  let(:journey) { described_class.new(config) }

  context 'valid journeys' do
    after do
      remove_data_source_class
    end

    it 'should return windows page when os adviser data source returns windows' do
      make_data_source_methods('windows', '')
      current_step = journey.start
      expect(current_step.name).to eq('intro')
      current_step = journey.perform_action(current_step, 'proceed')
      expect(current_step.name).to eq('windows')
      current_step = journey.perform_action(current_step, 'finish')
      expect(current_step.name).to eq('completed')
    end

    it 'should return linux apt-get page when os adviser data source returns linux and apt' do
      make_data_source_methods('linux', 'apt')
      current_step = journey.start
      expect(current_step.name).to eq('intro')
      current_step = journey.perform_action(current_step, 'proceed')
      expect(current_step.name).to eq('linux apt-get')
      current_step = journey.perform_action(current_step, 'finish')
      expect(current_step.name).to eq('completed')
    end

    it 'should throw an error when no matching transition is found' do
      make_data_source_methods('linux', 'wget')
      current_step = journey.start
      expect(current_step.name).to eq('intro')
      expect { journey.perform_action(current_step, 'proceed') }
        .to raise_error(JourneyWalker::JourneyError, /proceed.*intro|intro*.proceed/)
    end
  end
end
