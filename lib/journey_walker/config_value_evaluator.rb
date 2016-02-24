require 'r18n-core'
require_relative 'journey_error'

module JourneyWalker
  # This class takes a config value, and evaluates it hierarchically so that all parameters which require their
  # own config values are executed first etc.  This is also the point where data sources are chosen based on
  # the 'type'
  class ConfigValueEvaluator
    include R18n::Helpers

    def initialize(config, services = {})
      @config = config
      @services = services
    end

    def evaluate(value, action_params)
      return evaluate_source(value, action_params) if value.respond_to?(:source)
      return evaluate_action_param(value, action_params) if value.respond_to?(:type) && value.type == 'action_param'
      value
    end

    private

    def evaluate_action_param(action_param_definition, action_params)
      unless action_params.key?(action_param_definition.name.to_sym)
        raise JourneyError, t.error.missing_action_parameter(action_param_definition.name, action_params.keys.join)
      end
      action_params[action_param_definition.name.to_sym]
    end

    def evaluate_source(source_call, action_params)
      data_source_config = data_source(source_call.source)

      # Map all the parameters to basic values rather than source calls
      parameters = []
      parameters = source_call.parameters.map do |parameter|
        OpenStruct.new(name: parameter.name, value: evaluate(parameter.value, action_params))
      end if source_call.respond_to?(:parameters)

      data_source_class = JourneyWalker::DataSource.find_data_source(data_source_config.type)[0]
      data_source_class.new.evaluate(data_source_config, source_call.source_method, parameters, @services)
    end

    def data_source(source_name)
      @config.data_sources.find { |source| source.name == source_name }
    end
  end
end
