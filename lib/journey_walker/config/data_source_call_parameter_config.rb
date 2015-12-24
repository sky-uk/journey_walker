module JourneyWalker
  module Config
    # Holds the details for a parameter to a data source call
    class DataSourceCallParameterConfig
      attr_reader :name, :value

      def initialize(name, value)
        @name = name
        @value = value
      end
    end
  end
end
