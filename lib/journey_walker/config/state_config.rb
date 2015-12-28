module JourneyWalker
  module Config
    # Holds the configuration for a journey state
    class StateConfig
      attr_reader :name

      def initialize(state_name)
        @name = state_name
      end
    end
  end
end
