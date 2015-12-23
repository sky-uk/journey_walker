require_relative 'config_validator'
require_relative 'step_config'
require_relative 'data_source_config'
require_relative 'transition_config'
require_relative 'data_switch_config'

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
          DataSourceConfig.new(source[:name],
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
          DataSwitchConfig.new(data_switch[:source],
                               data_switch[:method],
                               data_switch[:value])
        end
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
