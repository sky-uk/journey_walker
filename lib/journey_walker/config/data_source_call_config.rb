module JourneyWalker
  module Config
    # Holds the details for a call to a data source
    class DataSourceCallConfig
      attr_reader :source, :source_method

      def initialize(source, source_method)
        @source = source
        @source_method = source_method
      end
    end
  end
end
