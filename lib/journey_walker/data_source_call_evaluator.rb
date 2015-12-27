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
      JourneyWalker::DataSources::Custom.new.evaluate(data_source, source_call)
    end
  end
end
