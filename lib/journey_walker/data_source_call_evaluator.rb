module JourneyWalker
  # This class takes a data source call, and evaluates it hierarchically so that all parameters which require their
  # own data source calls are executed first etc.  This is also the point where data sources are chosen based on
  # the 'type'
  class DataSourceCallEvaluator
    def initialize(config)
      @config = config
    end

    def evaluate(source_call)
      data_source = @config.data_source(source_call.source)
      # Map all the parameters to basic values rather than source calls
      parameters = source_call.parameters.map do |parameter|
        JourneyWalker::Config::DataSourceCallParameterConfig.new(parameter.name, evaluate_parameter(parameter.value))
      end
      JourneyWalker::DataSources::Custom.new.evaluate(data_source, source_call.source_method, parameters)
    end

    private

    # There are two types of parameter values - data source calls and regular values.  This method switches between
    # them.
    def evaluate_parameter(value)
      return value unless value.respond_to?(:source)
      evaluate(value)
    end
  end
end
