
# Definition of a transition in a journey
#   from: The step name which this transition begins from
#   to: The name of the step this transition moves to
#   action: The name of the action initiating the transition
#   data_switches: Rules around when this transition can happen
class TransitionConfig
  attr_reader :from, :to, :action, :data_switches

  def initialize(from, to, action, data_switches)
    @from = from
    @to = to
    @action = action
    @data_switches = data_switches
  end
end
