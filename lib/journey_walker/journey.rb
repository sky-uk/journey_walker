require_relative 'config/journey_config'
require_relative 'journey_error'

module JourneyWalker
  # This is the class which manages a journeyman journey, loaded from the json representation.
  class Journey
    def initialize(config)
      @config = JourneyWalker::Config::JourneyConfig.new(config)
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
        data_source = @config.data_source(data_switch.source)
        data_source_class = data_source_class(data_source)

        response = call_data_source_method(data_source_class, data_switch)
        return false unless response
      end
      true
    end

    def call_data_source_method(data_source_class, data_switch)
      method_response = data_source_class.new.send(data_switch.method)
      return method_response == data_switch.value
    rescue
      raise(JourneyError, "Cannot find data source method '#{data_switch.method}'")
    end

    def data_source_class(data_source)
      data_source.class_name.split('::').inject(Kernel) do |scope, module_or_class|
        scope.const_get(module_or_class)
      end
    rescue
      raise(JourneyError, "Cannot find data source class '#{data_source.class_name}' "\
                        "for data source '#{data_source.name}'")
    end

    def validate_actions(action, current_step, transitions)
      fail JourneyError,
           "Could not find action '#{action}' for step '#{current_step.name}'" if transitions.empty?
      fail JourneyError,
           "Too many actions for action named '#{action}' for step '#{current_step.name}'" if transitions.size > 1
    end

    def initial_step
      @config.step(@config.transitions.find { |transition| transition.from.nil? }.to)
    end
  end
end
