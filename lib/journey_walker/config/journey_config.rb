require_relative 'config_validator'
require_relative 'state_config'
require_relative '../data_sources/custom_config'
require_relative 'transition_config'
require_relative 'condition_config'
require_relative 'data_source_call_config'
require_relative 'data_source_call_parameter_config'

module JourneyWalker
  module Config
    # Holds the config used by the journey
    class JourneyConfig
      attr_reader :transitions

      def initialize(config)
        ConfigValidator.new.validate(config)
        parse(config)
      end

      def state(state_name)
        @states.find { |state| state.name == state_name }
      end

      def data_source(source_name)
        @data_sources.find { |source| source.name == source_name }
      end

      private

      def parse(config)
        @states = parse_states(config[:states])
        @data_sources = parse_data_sources(config[:data_sources]) unless config[:data_sources].nil?
        @transitions = parse_transitions(config[:transitions])
      end

      def parse_states(states_hash)
        states_hash.collect { |state| StateConfig.new(state[:name]) }
      end

      def parse_data_sources(data_sources_hash)
        data_sources_hash.collect do |source|
          JourneyWalker::DataSources::CustomConfig.new(source[:name],
                                                       source[:class_name],
                                                       source[:methods])
        end
      end

      def parse_transitions(transitions_hash)
        transitions_hash.collect do |transition|
          TransitionConfig.new(transition[:from],
                               transition[:to],
                               transition[:action],
                               parse_conditions(transition[:conditions]))
        end
      end

      def parse_conditions(conditions)
        return [] if conditions.nil?
        conditions.collect do |condition|
          ConditionConfig.new(condition[:value],
                              parse_source_call(condition[:source_call]))
        end
      end

      def parse_source_call(source_call)
        DataSourceCallConfig.new(source_call[:source], source_call[:method], parse_parameters(source_call[:parameters]))
      end

      def parse_parameters(parameters)
        return [] if parameters.nil?
        parameters.map { |param| DataSourceCallParameterConfig.new(param[:name], parse_param_value(param[:value])) }
      end

      def parse_param_value(param_value)
        return param_value unless param_value.is_a?(Hash) && param_value.key?(:source)
        parse_source_call(param_value)
      end
    end
  end
end
