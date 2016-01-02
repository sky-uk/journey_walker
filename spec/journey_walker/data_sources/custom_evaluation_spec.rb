require_relative '../../spec_helper'
require_relative '../../../lib/journey_walker/data_sources/custom_config'
require_relative '../../../lib/journey_walker'
require_relative '../../../lib/journey_walker/data_sources/custom'
require_relative '../../../lib/journey_walker/journey_error'
require_relative '../../../lib/journey_walker/config/parameter_config'

describe JourneyWalker::DataSources::Custom do
  let(:data_source) do
    JourneyWalker::DataSources::CustomConfig.new('OS Advisor',
                                                 'SomeThing::SomeWhere::OSAdviser',
                                                 %w(os install_method))
  end

  context 'data source class not found' do
    before do
      make_data_source_module
    end

    it 'should raise an error when the data source class cannot be found' do
      expect { described_class.new.evaluate(data_source, 'os', []) }
        .to raise_error(JourneyWalker::JourneyError, /'SomeThing::SomeWhere::OSAdviser'/i)
    end
  end

  context 'data source method not found' do
    before do
      make_data_source_class
    end

    it 'should raise an error when the data source method cannot be found' do
      expect { described_class.new.evaluate(data_source, 'os', []) }
        .to raise_error(JourneyWalker::JourneyError, /'os'/i)
    end
  end

  context 'gets data source response' do
    before do
      make_data_source_methods('linux', 'apt')
    end

    it 'should return true for matching switch' do
      expect(described_class.new.evaluate(data_source, 'os', [])).to eq('linux')
    end
  end

  context 'gets data source response dependant on parameters' do
    before do
      make_data_source_methods('linux', 'apt')
    end
    let(:parameters) { [JourneyWalker::Config::ParameterConfig.new('capitalise', true)] }
    let(:parameters) { [JourneyWalker::Config::ParameterConfig.new('capitalise', true)] }

    it 'should return true for matching switch' do
      expect(described_class.new.evaluate(data_source, 'os', parameters)).to eq('Linux')
    end
  end
end
