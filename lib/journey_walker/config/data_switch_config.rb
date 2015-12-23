
# Data switch definition
#   source: The name of the data source
#   method: The method to call on the data source
#   value: The value which should match the response from the data source method to count as true
class DataSwitchConfig
  attr_reader :source, :method, :value

  def initialize(source, method, value)
    @source = source
    @method = method
    @value = value
  end
end
