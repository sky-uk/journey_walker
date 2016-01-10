module JourneyWalker
  # This class takes a config value, and evaluates it hierarchically so that all parameters which require their
  # own config values are executed first etc.  This is also the point where data sources are chosen based on
  # the 'type'
  class ConfigValueEvaluator
    def initialize(config)
      @config = config
    end

    def evaluate(value)
      return value unless value.respond_to?(:source)
      evaluate_source(value)
    end

    private

    def evaluate_source(source_call)
      data_source_config = data_source(source_call.source)

      # Map all the parameters to basic values rather than source calls
      parameters = []
      parameters = source_call.parameters.map do |parameter|
        OpenStruct.new(name: parameter.name, value: evaluate(parameter.value))
      end if source_call.respond_to?(:parameters)

      data_source_class = JourneyWalker::DataSource.find_data_source(data_source_config.type)[0]
      data_source_class.new.evaluate(data_source_config, source_call.source_method, parameters)
    end

    def data_source(source_name)
      @config.data_sources.find { |source| source.name == source_name }
    end
  end
end
