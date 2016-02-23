# Should be tidied out of here, just some random methods to call from custom data sources in tests
class JourneyWalkerTests
  @numeric_value = 1

  def initialize(services)
    @os_service=services[:os_service]
  end

  def service_call
    @os_service.service_method
  end

  def multiply(x, y)
    x * y
  end

  def fetch_number(number)
    number
  end

  # pretty sure this will mess up if we use concurrently executing tests but will do for now
  def self.update_numeric_class_value(number)
    @numeric_value = number
  end

  def update_numeric_value(number)
    self.class.update_numeric_class_value(number)
  end

  def self.fetch_numeric_class_value
    @numeric_value
  end

  def fetch_numeric_value
    self.class.fetch_numeric_class_value
  end
end
