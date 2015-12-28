module JourneyWalker
  module Config
    # Data switch definition
    #   value: The value which should match the response from the data source method to count as true
    #   source_call: The definition of the call to make
    class DataSwitchConfig
      attr_reader :value, :source_call

      def initialize(value, source_call)
        @value = value
        @source_call = source_call
      end
    end
  end
end
