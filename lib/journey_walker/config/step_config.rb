module JourneyWalker
  module Config
    # Holds the configuration for a journey step
    class StepConfig
      attr_reader :name

      def initialize(step_name)
        @name = step_name
      end
    end
  end
end
