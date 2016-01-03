require_relative '../../spec_helper'
require_relative '../../../lib/journey_walker/data_sources/custom'
require_relative '../../../lib/journey_walker/journey_error'

describe JourneyWalker::DataSources::Custom do
  let(:config_error) { JourneyWalker::Config::InvalidConfigError }
  let(:data_source) do
    class_param = OpenStruct.new(name: 'class_name', value: 'SomeThing::SomeWhere::OSAdviser')
    OpenStruct.new(type: 'custom', name: 'OS Advisor', parameters: [class_param])
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
    let(:parameters) { [OpenStruct.new(name: 'capitalise', value: true)] }

    it 'should return true for matching switch' do
      expect(described_class.new.evaluate(data_source, 'os', parameters)).to eq('Linux')
    end
  end

  it 'should have type of custom' do
    expect { described_class.validate(type: 'non-custom') }.to raise_error(config_error)
  end

  context 'data source class not found' do
    before do
      make_data_source_module
    end

    it 'should raise an error when the data source class cannot be found' do
      invalid_params = [{ name: 'class_name', value: 'SomeThing::SomeWhere::OSAdviser' }]
      expect { described_class.validate(type: 'custom', parameters: invalid_params) }
        .to raise_error(config_error, /cannot find data source class 'SomeThing::SomeWhere::OSAdviser'/i)
    end
  end
end
