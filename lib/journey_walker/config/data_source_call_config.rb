module JourneyWalker
  module Config
    # Holds the details for a call to a data source
    class DataSourceCallConfig
      attr_reader :source, :source_method, :parameters

      def initialize(source, source_method, parameters)
        @source = source
        @source_method = source_method
        @parameters = parameters
      end
    end
  end
end
