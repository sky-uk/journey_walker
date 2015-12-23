module JourneyWalker
  module Config
    # Definition of the data source
    #   name: A unique identifier for the data source (referred to by the data switch)
    #   class_name: The ruby class used to fulfill the data source
    #   methods: the name of the methods to call
    class DataSourceConfig
      attr_reader :name, :class_name, :methods

      def initialize(source_name, class_name, methods)
        @name = source_name
        @class_name = class_name
        @methods = methods
      end
    end
  end
end
