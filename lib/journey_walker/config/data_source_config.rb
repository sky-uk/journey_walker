module JourneyWalker
  module Config
    # Definition of the data source
    #   name: A unique identifier for the data source (referred to by the condition)
    #   type: The type of data source to use
    #   parameters: All the data source specific config
    class DataSourceConfig
      attr_reader :type, :name, :parameters

      def initialize(type, name, parameters)
        @type = type
        @name = name
        @parameters = parameters
      end

      def parameter(parameter_name)
        @parameters.find { |parameter| parameter.name == parameter_name }
      end
    end
  end
end
