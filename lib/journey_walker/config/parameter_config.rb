module JourneyWalker
  module Config
    # Holds the details for a parameter, if the value is an object responding to "source" it will
    # be considered a data source call and executed appropriately.
    class ParameterConfig
      attr_reader :name, :value

      def initialize(name, value)
        @name = name
        @value = value
      end
    end
  end
end
