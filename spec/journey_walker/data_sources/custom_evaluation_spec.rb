require_relative '../../spec_helper'
require_relative '../../../lib/journey_walker/data_sources/custom_config'
require_relative '../../../lib/journey_walker'
require_relative '../../../lib/journey_walker/data_sources/custom'
require_relative '../../../lib/journey_walker/journey_error'

describe JourneyWalker::DataSources::Custom do
  let(:data_source) do
    JourneyWalker::DataSources::CustomConfig.new('OS Advisor',
                                                 'SomeThing::SomeWhere::OSAdviser',
                                                 %w(os install_method))
  end
  let(:data_source_call) { JourneyWalker::Config::DataSourceCallConfig.new('OS Advisor', 'os') }
  let(:data_switch) { JourneyWalker::Config::DataSwitchConfig.new('linux', data_source_call) }

  context 'data source class not found' do
    before do
      make_data_source_module
    end

    it 'should raise an error when the data source class cannot be found' do
      expect { described_class.new.evaluate(data_source, data_source_call) }
        .to raise_error(JourneyWalker::JourneyError, /cannot find data source class 'SomeThing::SomeWhere::OSAdviser'/i)
    end
  end

  context 'data source method not found' do
    before do
      make_data_source_class
    end

    it 'should raise an error when the data source method cannot be found' do
      expect { described_class.new.evaluate(data_source, data_source_call) }
        .to raise_error(JourneyWalker::JourneyError, /cannot find data source method 'os'/i)
    end
  end

  context 'gets data source response' do
    before do
      make_data_source_methods('linux', 'apt')
    end

    it 'should return true for matching switch' do
      expect(described_class.new.evaluate(data_source, data_source_call)).to eq('linux')
    end
  end
end
