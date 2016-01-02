module JourneyWalker
  module Config
    # Definition of a transition in a journey
    #   from: The state name which this transition begins from
    #   to: The name of the state this transition moves to
    #   action: The name of the action initiating the transition
    #   conditions: Rules around when this transition can happen
    #   data: Any associated data - gets returned when actions are queried
    class TransitionConfig
      attr_reader :from, :to, :action, :conditions, :data

      def initialize(from, to, action, conditions, data)
        @from = from
        @to = to
        @action = action
        @conditions = conditions
        @data = data
      end
    end
  end
end
