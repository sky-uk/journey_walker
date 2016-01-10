require 'simplecov'
SimpleCov.start do
  SimpleCov.minimum_coverage 100
end

require_relative '../lib/journey_walker'
require_relative 'journey_walker/helpers/journey_walker_tests'
require_relative 'journey_walker/helpers/class_builder'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include ClassBuilder
end
