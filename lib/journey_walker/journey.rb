require 'r18n-core'
require_relative 'config/journey_config'
require_relative 'journey_error'
require_relative 'data_sources/custom'
require_relative 'data_source_call_evaluator'

module JourneyWalker
  # This is the class which manages a journeyman journey, loaded from the json representation.
  class Journey
    include R18n::Helpers

    def initialize(config)
      @config = JourneyWalker::Config::JourneyConfig.new(config)
      @data_source_evaluator = JourneyWalker::DataSourceCallEvaluator.new(@config)
    end

    def start
      initial_step
    end

    def perform_action(current_step, action)
      transitions = @config.transitions.find_all do |potential_transition|
        evaluate_transition(action, current_step, potential_transition)
      end
      validate_actions(action, current_step, transitions)
      @config.step(transitions[0].to)
    end

    private

    def evaluate_transition(action, current_step, potential_transition)
      potential_transition.from == current_step.name &&
        potential_transition.action == action &&
        evaluate_data_switches(potential_transition)
    end

    def evaluate_data_switches(potential_transition)
      return true if potential_transition.data_switches.nil?

      potential_transition.data_switches.each do |data_switch|
        source_response = @data_source_evaluator.evaluate(data_switch.source_call)
        return false unless source_response == data_switch.value
      end
      true
    end

    def validate_actions(action, current_step, transitions)
      fail JourneyError, t.error.unknown_action(action, current_step.name) if transitions.empty?
      fail JourneyError, t.error.too_many_actions(action, current_step.name) if transitions.size > 1
    end

    def initial_step
      @config.step(@config.transitions.find { |transition| transition.from.nil? }.to)
    end
  end
end
