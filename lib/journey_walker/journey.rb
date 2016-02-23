require 'r18n-core'
require_relative 'config/journey_loader'
require_relative 'journey_error'
require_relative 'data_sources/custom'
require_relative 'config_value_evaluator'

module JourneyWalker
  # This is the class which manages a journeyman journey, loaded from the json representation.
  class Journey
    include R18n::Helpers

    def initialize(config, services={})
      @config = JourneyWalker::Config::JourneyLoader.load(config)
      @config_value_evaluator = JourneyWalker::ConfigValueEvaluator.new(@config, services)
    end

    def start
      state_to_state_hash(initial_state)
    end

    def perform_action(current_state_name, action, action_params: {})
      current_state = state(current_state_name)
      transitions = @config.transitions.find_all do |potential_transition|
        evaluate_transition_for_action(action, current_state, potential_transition, action_params)
      end
      validate_actions(action, current_state, transitions)
      fire_events(transitions[0], action_params)
      current_state(transitions[0].to)
    end

    def allowed_actions(current_state_name, action_params: {})
      current_state = state(current_state_name)
      transitions = @config.transitions.find_all do |potential_transition|
        evaluate_transition(current_state, potential_transition, action_params)
      end
      transition_to_action_hash(transitions).uniq
    end

    def current_state(current_state_name)
      state_to_state_hash(state(current_state_name))
    end

    private

    def fire_events(transition, action_params)
      return if transition.events.nil?
      transition.events.each do |event|
        @config_value_evaluator.evaluate(event, action_params)
      end
    end

    def state_to_state_hash(state)
      name = state.name
      data = name_value_to_hash(state.data)
      { name: name, data: data }
    end

    def name_value_to_hash(name_value_array)
      result = {}
      name_value_array.each do |row|
        # Note how action params are not sent through here - we aren't performing an action.
        result[row[:name].to_sym] = @config_value_evaluator.evaluate(row[:value], action_params: {})
      end unless name_value_array.nil?
      result
    end

    def transition_to_action_hash(transitions)
      transitions.map do |transition|
        name = transition.action
        data = transition.data.nil? ? nil : transition.data.marshal_dump
        { name: name, data: data }
      end
    end

    def evaluate_transition(current_state, potential_transition, action_params)
      potential_transition.from == current_state.name &&
        evaluate_conditions(potential_transition, action_params)
    end

    def evaluate_transition_for_action(action, current_state, potential_transition, action_params)
      potential_transition.from == current_state.name &&
        potential_transition.action == action &&
        evaluate_conditions(potential_transition, action_params)
    end

    def evaluate_conditions(potential_transition, action_params)
      return true if potential_transition.conditions.nil?

      potential_transition.conditions.each do |condition|
        source_response = @config_value_evaluator.evaluate(condition.source_call, action_params)
        return false unless source_response == condition.value
      end
      true
    end

    def validate_actions(action, current_state, transitions)
      raise JourneyError, t.error.unknown_action(action, current_state.name) if transitions.empty?
      raise JourneyError, t.error.too_many_actions(action, current_state.name) if transitions.size > 1
    end

    def initial_state
      state(@config.transitions.find { |transition| transition.from.nil? }.to)
    end

    def state(state_name)
      @config.states.find { |state| state.name == state_name }
    end
  end
end
