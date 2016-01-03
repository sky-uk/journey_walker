module JourneyWalker
  # This is the base class of all data sources - descendants of this class are found when deciding how to make a data
  # source call
  class DataSource
    def self.find_data_source(data_source_type)
      ObjectSpace.each_object(Class).select do |klass|
        klass < JourneyWalker::DataSource && klass.data_source_type == data_source_type
      end
    end

    def self.config_error(message)
      fail(JourneyWalker::Config::InvalidConfigError, message)
    end
  end
end