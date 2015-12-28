module JourneyWalker
  module Config
    # Definition of a transition in a journey
    #   from: The state name which this transition begins from
    #   to: The name of the state this transition moves to
    #   action: The name of the action initiating the transition
    #   conditions: Rules around when this transition can happen
    class TransitionConfig
      attr_reader :from, :to, :action, :conditions

      def initialize(from, to, action, conditions)
        @from = from
        @to = to
        @action = action
        @conditions = conditions
      end
    end
  end
end
