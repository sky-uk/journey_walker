module JourneyWalker
  # This is class which contains helpers to build config.
  module ConfigHelper
    def self.merge_transitions(original_transitions, new_transitions)
      merged_transitions = original_transitions.inject([]) { |a, e| a << e.dup }

      add_new_to_original(new_transitions, merged_transitions)

      merged_transitions
    end

    def self.transitions_match(new_transition, merged_transition)
      action_and_from_match(new_transition, merged_transition) &&
        (
          both_have_no_conditions(new_transition, merged_transition) ||
          only_new_has_conditions(new_transition, merged_transition) ||
          only_old_has_conditions(new_transition, merged_transition)
        )
    end

    def self.add_new_to_original(new_transitions, merged_transitions)
      new_transitions.each do |new_transition|
        match_position = merged_transitions.find_index do |merged_transition|
          transitions_match(new_transition, merged_transition)
        end

        merged_transitions.delete_if do |merged_transition|
          transitions_match(new_transition, merged_transition)
        end if match_position

        merged_transitions << new_transition
      end
    end

    def self.action_and_from_match(new_transition, merged_transition)
      new_transition[:action] == merged_transition[:action] &&
        new_transition[:from] == merged_transition[:from]
    end

    def self.both_have_no_conditions(new_transition, merged_transition)
      new_transition[:conditions].nil? && merged_transition[:conditions].nil?
    end

    def self.only_new_has_conditions(new_transition, merged_transition)
      !new_transition[:conditions].nil? && merged_transition[:conditions].nil?
    end

    def self.only_old_has_conditions(new_transition, merged_transition)
      new_transition[:conditions].nil? && !merged_transition[:conditions].nil?
    end
  end
end
