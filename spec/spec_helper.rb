require 'simplecov'
SimpleCov.start do
  SimpleCov.minimum_coverage 100
end

# Builds SomeThing::SomeWhere::OSAdviser with some methods.  May not be the best way to do this.
module ClassBuilder
  def make_data_source_methods(os, install_method)
    make_data_source_class
    SomeThing::SomeWhere::OSAdviser.send(:define_method, 'os') { |capitalise = false| capitalise ? os.capitalize : os }
    SomeThing::SomeWhere::OSAdviser.send(:define_method, 'install_method') { install_method }
  end

  def make_data_source_class
    some_where = make_data_source_module
    some_where.const_set(:OSAdviser, Class.new)
  end

  def make_data_source_module
    some_thing = Kernel.const_set(:SomeThing, Module.new)
    some_thing.const_set(:SomeWhere, Module.new)
  end

  def remove_data_source_class
    some_thing = Kernel.const_get(:SomeThing)
    some_where = some_thing.const_get(:SomeWhere)
    some_where.send(:remove_const, :OSAdviser)
  end
end

# Should be tidied out of here, just some random methods to call from custom data sources in tests
class JourneyWalkerTests
  def multiply(x, y)
    x * y
  end

  def fetch_number(number)
    number
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include ClassBuilder
end
