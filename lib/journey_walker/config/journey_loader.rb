require_relative 'config_validator'
require 'recursive_open_struct'

module JourneyWalker
  module Config
    # Holds the config used by the journey
    class JourneyLoader
      def self.load(config)
        ConfigValidator.new.validate(config)
        RecursiveOpenStruct.new(config, recurse_over_arrays: true)
      end
    end
  end
end
