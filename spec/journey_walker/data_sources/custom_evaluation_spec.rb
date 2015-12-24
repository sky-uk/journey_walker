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
  let(:data_switch) { JourneyWalker::Config::DataSwitchConfig.new('OS Advisor', 'os', 'linux') }

  context 'data source class not found' do
    before do
      make_data_source_module
    end

    it 'should raise an error when the data source class cannot be found' do
      expect { described_class.new.evaluate(data_source, data_switch) }
        .to raise_error(JourneyWalker::JourneyError, /cannot find data source class 'SomeThing::SomeWhere::OSAdviser'/i)
    end
  end

  context 'data source method not found' do
    before do
      make_data_source_class
    end

    it 'should raise an error when the data source method cannot be found' do
      expect { described_class.new.evaluate(data_source, data_switch) }
        .to raise_error(JourneyWalker::JourneyError, /cannot find data source method 'os'/i)
    end
  end

  context 'data source matches switch' do
    before do
      make_data_source_methods('linux', 'apt')
    end

    it 'should return true for matching switch' do
      expect(described_class.new.evaluate(data_source, data_switch)).to eq(true)
    end
  end

  context 'data source does not match switch' do
    before do
      make_data_source_methods('windows', 'apt')
    end

    it 'should return true for matching switch' do
      expect(described_class.new.evaluate(data_source, data_switch)).to eq(false)
    end
  end
end
