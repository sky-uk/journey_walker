require_relative 'journeyman_invalid_config_error'

# Runs all validations on the config file
class JourneyConfigValidator
  def self.validate(config)
    validate_transitions(config[:transitions])
  end

  private_class_method def self.validate_transitions(transitions_config)
    config_error('No transitions are defined in journey.') unless
        !transitions_config.nil? && !transitions_config.empty?
    config_error('No initial transition defined (transition with only "to:" key.)') unless
        transitions_config.any? { |value| !value.key?(:from) }
    transitions_config.each do |transition|
      validate_transition(transition)
    end
  end

  private_class_method def self.validate_transition(transition)
    config_error('no to: defined on transition') unless
        transition.key?(:to) || transition[:action] == 'start'
    config_error('no action defined on transition') unless
        transition.key?(:action)
  end

  private_class_method def self.config_error(message)
    fail(JourneymanInvalidConfigError, message)
  end
end
