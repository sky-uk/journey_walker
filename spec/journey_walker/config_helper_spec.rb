require_relative '../../lib/journey_walker/helpers/config_helper.rb'

describe JourneyWalker::ConfigHelper do
  let(:original_transitions) do
    [
      {
        from: 'here',
        action: 'walk'
      }
    ]
  end

  let(:new_transitions) do
    [
      {
        from: 'here',
        action: 'jump'
      }
    ]
  end

  let(:merged) { described_class.merge_transitions(original_transitions, new_transitions) }

  it 'return new array with both merged transitions' do
    expect(merged).to eq(original_transitions.concat(new_transitions))
  end

  context 'matching transitions' do
    let(:new_transitions) do
      [
        {
          from: 'here',
          action: 'walk',
          to: 'moon'
        }
      ]
    end

    it 'replaces matching original transitions with new transitions' do
      expect(merged).to eq(new_transitions)
    end
  end

  context 'matching transitions with conditions' do
    let(:original_transitions) do
      [
        {
          from: 'here',
          action: 'walk',
          conditions: 'STRING'
        }
      ]
    end

    let(:new_transitions) do
      [
        {
          from: 'here',
          action: 'walk',
          conditions: 'Stringy'
        }
      ]
    end

    it 'concats when they both have conditions' do
      expect(merged).to eq(original_transitions.concat(new_transitions))
    end
  end

  context 'matching transitions with conditions' do
    let(:new_transitions) do
      [
        {
          from: 'here',
          action: 'walk',
          conditions: 'Stringy'
        }
      ]
    end

    it 'overrides when the new transition has condition and the original one doesnt' do
      expect(merged).to eq(new_transitions)
    end
  end

  context 'matching transitions with conditions' do
    let(:original_transitions) do
      [
        {
          from: 'here',
          action: 'jump',
          conditions: 'STRING'
        },
        {
          from: 'here',
          action: 'jump',
          conditions: 'STRING2'
        }
      ]
    end

    it 'overrides when the original transitions have conditions and the new one doesnt' do
      expect(merged).to eq(new_transitions)
    end
  end
end
