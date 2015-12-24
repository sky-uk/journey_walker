require_relative 'config_validator'
require_relative 'step_config'
require_relative '../data_sources/custom_config'
require_relative 'transition_config'
require_relative 'data_switch_config'
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

      def parse(config)
        @steps = parse_steps(config[:steps])
        @data_sources = parse_data_sources(config[:data_sources]) unless config[:data_sources].nil?
        @transitions = parse_transitions(config[:transitions])
      end

      def parse_steps(steps_hash)
        steps_hash.collect { |step| StepConfig.new(step[:name]) }
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
                               parse_data_switches(transition[:data_switches]))
        end
      end

      def parse_data_switches(data_switches)
        return [] if data_switches.nil?
        data_switches.collect do |data_switch|
          DataSwitchConfig.new(data_switch[:value],
                               parse_source_call(data_switch[:source_call]))
        end
      end

      def parse_source_call(source_call)
        DataSourceCallConfig.new(source_call[:source], source_call[:method], parse_parameters(source_call[:parameters]))
      end

      def parse_parameters(parameters)
        return [] if parameters.nil?
        parameters.map { |param| DataSourceCallParameterConfig.new(param[:name], param[:value]) }
      end

      def step(step_name)
        @steps.find { |step| step.name == step_name }
      end

      def data_source(source_name)
        @data_sources.find { |source| source.name == source_name }
      end
    end
  end
end
