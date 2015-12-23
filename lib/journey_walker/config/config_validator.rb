require_relative 'invalid_config_error'

module JourneyWalker
  module Config
    # Runs all validations on the config file
    class ConfigValidator
      def self.validate(config)
        validate_transitions(config[:transitions])
      end

      def self.validate_transitions(transitions_config)
        if transitions_config.nil? || transitions_config.empty?
          config_error('No transitions are defined in journey.')
        end

        if transitions_config.none? { |value| !value.key?(:from) }
          config_error('No initial transition defined (transition with only "to:" key.)')
        end

        transitions_config.each do |transition|
          validate_transition(transition)
        end
      end

      def self.validate_transition(transition)
        config_error('no to: defined on transition') unless transition.key?(:to) || transition[:action] == 'start'
        config_error('no action defined on transition') unless transition.key?(:action)
      end

      def self.config_error(message)
        fail(InvalidConfigError, message)
      end
    end
  end
end
