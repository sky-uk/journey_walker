require_relative '../../spec_helper'
require_relative '../../../lib/journey_walker'
require_relative '../../../lib/journey_walker/data_sources/custom'
require_relative '../../../lib/journey_walker/config/invalid_config_error'

describe JourneyWalker::DataSources::Custom do
  let(:config_error) { JourneyWalker::Config::InvalidConfigError }

  it 'should have type of custom' do
    expect { described_class.new.validate(type: 'non-custom') }.to raise_error(config_error)
  end

  context 'data source class not found' do
    before do
      make_data_source_module
    end

    it 'should raise an error when the data source class cannot be found' do
      expect { described_class.new.validate(type: 'custom', class_name: 'SomeThing::SomeWhere::OSAdviser') }
        .to raise_error(config_error, /cannot find data source class 'SomeThing::SomeWhere::OSAdviser'/i)
    end
  end
end
