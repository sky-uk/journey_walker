require_relative '../../lib/journey_walker/journey'
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
describe Journey do
  let(:config) { JSON.parse(File.read('spec/journey_walker/config/installer.json'), symbolize_names: true) }
  let(:journey) { Journey.new(config) }

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
        .to raise_error(JourneyError, /proceed.*intro|intro*.proceed/)
    end
  end

  context 'data source class not found' do
    before do
      make_data_source_module
    end

    it 'should raise an error when the data source class cannot be found' do
      current_step = journey.start
      expect { journey.perform_action(current_step, 'proceed') }
        .to raise_error(JourneyError, /cannot find data source class 'SomeThing::SomeWhere::OSAdviser'/i)
    end
  end

  context 'data source method not found' do
    before do
      make_data_source_class
    end

    it 'should raise an error when the data source method cannot be found' do
      current_step = journey.start
      expect { journey.perform_action(current_step, 'proceed') }
        .to raise_error(JourneyError, /cannot find data source method 'os'/i)
    end
  end

  def make_data_source_methods(os, install_method)
    make_data_source_class
    SomeThing::SomeWhere::OSAdviser.send(:define_method, 'os') { os }
    SomeThing::SomeWhere::OSAdviser.send(:define_method, 'install_method') { install_method }
  end

  def make_data_source_class
    some_where = make_data_source_module
    some_where.const_set(:OSAdviser, Class.new)
  end

  def make_data_source_module
    some_thing = Kernel.const_set(:SomeThing, Module.new)
    some_thing.const_set(:SomeWhere, Module.new)
  end

  def remove_data_source_class
    some_thing = Kernel.const_get(:SomeThing)
    some_where = some_thing.const_get(:SomeWhere)
    some_where.send(:remove_const, :OSAdviser)
  end
end
