module JourneyWalker
  module Config
    # Holds the details for a parameter to a data source call, the value can be either a fixed string or
    # a data source call config object
    class DataSourceCallParameterConfig
      attr_reader :name, :value

      def initialize(name, value)
        @name = name
        @value = value
      end
    end
  end
end
