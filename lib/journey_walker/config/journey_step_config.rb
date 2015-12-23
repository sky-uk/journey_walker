# Holds the configuration for a journey step
class JourneyStepConfig
  attr_reader :name

  def initialize(step_name)
    @name = step_name
  end
end
