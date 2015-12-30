require 'r18n-core'
require_relative 'invalid_config_error'

module JourneyWalker
  module Config
    # Runs all validations on the config file
    class ConfigValidator
      include R18n::Helpers

      def validate(config)
        @config = config
        validate_transitions(config[:transitions])
      end

      private

      def validate_transitions(transitions_config)
        validate_transitions_root(transitions_config)

        transitions_config.each do |transition|
          validate_transition(transition)
        end
      end

      def validate_transitions_root(transitions_config)
        config_error(t.error.no_transitions) if transitions_config.nil? || transitions_config.empty?
        config_error(t.error.no_initial_transition) if transitions_config.none? do |value|
          !value.key?(:from) && value[:action] == 'start'
        end
      end

      def validate_transition(transition)
        validate_to(transition)
        validate_from(transition)
        validate_action(transition)
        validate_conditions(transition)
      end

      def validate_conditions(transition)
        conditions = transition[:conditions]
        conditions.each do |condition|
          validate_condition(condition, transition)
        end unless conditions.nil? || !conditions.is_a?(Array)
      end

      def validate_condition(condition, transition)
        config_error(t.error.no_source_call(transition.to_json)) unless condition.key?(:source_call)
        config_error(t.error.no_value(transition.to_json)) unless condition.key?(:value)
        config_error(t.error.no_source(transition.to_json)) unless condition[:source_call].key?(:source)
        config_error(t.error.unknown_source(condition[:source_call][:source].to_json, transition.to_json)) unless
            data_source_exists(condition[:source_call][:source])
      end

      def validate_action(transition)
        config_error(t.error.no_action(transition.to_json)) unless transition.key?(:action)
      end

      def validate_to(transition)
        config_error(t.error.missing_to(transition.to_json)) unless transition.key?(:to) ||
                                                                    transition[:action] == 'start'
        config_error(t.error.invalid_state(transition[:to])) if transition.key?(:to) && !state_exists(transition[:to])
      end

      def validate_from(transition)
        config_error(t.error.invalid_state(transition[:from])) if
            transition.key?(:from) && !state_exists(transition[:from])
      end

      def state_exists(state_name)
        @config[:states].any? { |state| state[:name] == state_name }
      end

      def data_source_exists(source_name)
        @config[:data_sources].any? { |source| source[:name] == source_name }
      end

      def config_error(message)
        fail(InvalidConfigError, message)
      end
    end
  end
end
