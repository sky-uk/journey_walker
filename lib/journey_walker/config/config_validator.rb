require_relative 'invalid_config_error'

module JourneyWalker
  module Config
    # Runs all validations on the config file
    class ConfigValidator
      def validate(config)
        @config = config
        validate_transitions(config[:transitions])
      end

      def validate_transitions(transitions_config)
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

      def validate_transition(transition)
        validate_to(transition)
        validate_from(transition)
        validate_action(transition)
        validate_data_switches(transition)
      end

      def validate_data_switches(transition)
        data_switches = transition[:data_switches]
        data_switches.each do |data_switch|
          validate_data_switch(data_switch, transition)
        end unless data_switches.nil? || !data_switches.is_a?(Array)
      end

      def validate_data_switch(data_switch, transition)
        config_error("no source is defined for data switch '#{transition.to_json}'") unless data_switch.key?(:source)
        config_error("no method is defined for data switch '#{transition.to_json}'") unless data_switch.key?(:method)
        config_error("no value is defined for data switch '#{transition.to_json}'") unless data_switch.key?(:value)
        unknown_data_source = "data switch has unknown data source '#{data_switch[:source]}' in '#{transition.to_json}'"
        config_error(unknown_data_source) unless data_source_exists(data_switch[:source])
      end

      def validate_action(transition)
        config_error("no action defined on transition '#{transition.to_json}'") unless transition.key?(:action)
      end

      def validate_to(transition)
        config_error("no to: defined on transition '#{transition.to_json}'") unless transition.key?(:to) ||
                                                                                    transition[:action] == 'start'
        config_error("Invalid step name '#{transition[:to]}'") if transition.key?(:to) &&
                                                                  !step_exists(transition[:to])
      end

      def validate_from(transition)
        config_error("Invalid step name '#{transition[:from]}'") if transition.key?(:from) &&
                                                                    !step_exists(transition[:from])
      end

      def step_exists(step_name)
        @config[:steps].any? { |step| step[:name] == step_name }
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
