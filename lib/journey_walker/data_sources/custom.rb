require 'r18n-core'

module JourneyWalker
  module DataSources
    # This is the custom data source which allows you to create a new instance of any ruby class and call any methods
    # from that class, in each case passing parameters as necessary.
    # An example would be the OS Advisor data source from the tests which has the following config
    #
    # {
    #   "type": "custom",
    #   "name": "OS Advisor",
    #   "parameters": [
    #     {"name":"class_name", "value": "SomeThing::SomeWhere::OSAdviser"}
    #   ]
    # }
    #
    # This example does not expect any parameters, more complex examples are available in the tests
    #
    class Custom < JourneyWalker::DataSource
      include R18n::Helpers

      def self.data_source_type
        'custom'
      end

      def self.translate(*params)
        R18n.get.t(*params)
      end

      def self.validate(config)
        config_error(translate.data_source_error.wrong_type(config[:type], self.class)) if config[:type] != 'custom'
        class_name_param = config[:parameters].find { |parameter| parameter[:name] == 'class_name' }
        config_error(translate.data_source_error.missing_class_name(config)) if class_name_param.nil?
        class_name = class_name_param[:value]
        config_error(translate.data_source_error.missing_class(class_name)) if class_instance(class_name).nil?
      end

      def evaluate(data_source_config, method, parameters)
        data_source_class = data_source_class(data_source_config)
        call_data_source_method(data_source_class,
                                method,
                                parameters.map(&:value))
      end

      private

      def call_data_source_method(data_source_class, method, params)
        data_source_class.new.send(method, *params)
      rescue
        raise(JourneyError, t.error.data_source_method_missing(method))
      end

      def data_source_class(data_source)
        class_name_param = data_source.parameter('class_name')
        class_name_param.value.split('::').inject(Kernel) do |scope, module_or_class|
          scope.const_get(module_or_class)
        end
      rescue
        raise(JourneyError, t.error.data_source_class_missing(class_name_param.value, data_source.name))
      end

      def self.class_instance(class_name)
        class_name.split('::').inject(Kernel) do |scope, module_or_class|
          scope.const_get(module_or_class)
        end
      rescue
        nil
      end

      def self.config_error(message)
        fail(JourneyWalker::Config::InvalidConfigError, message)
      end
    end
  end
end
