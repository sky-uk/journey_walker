require 'r18n-core'

module JourneyWalker
  module DataSources
    # This is the custom data source which allows you to create a new instance of any ruby class and call any methods
    # from that class, in each case passing parameters as necessary.
    # And example would be the OS Advisor data source from the tests which has the following config
    #
    # {
    #   "type": "custom",
    #   "name": "OS Advisor",
    #   "class_name": "SomeThing::SomeWhere::OSAdviser",
    #   "methods": [
    #     "os",
    #     "install_method"
    #   ]
    # }
    #
    # This does not expect any parameters, mor complex examples are available in the tests
    #
    #
    # TODO: should be documented better
    class Custom
      include R18n::Helpers

      def validate(config)
        config_error(t.data_source_error.wrong_type(config[:type], self.class)) if config[:type] != 'custom'
        config_error(t.data_source_error.missing_class(config[:class_name])) if class_instance(config[:class_name]).nil?
      end

      def evaluate
      end

      private

      def class_instance(class_name)
        class_name.split('::').inject(Kernel) do |scope, module_or_class|
          scope.const_get(module_or_class)
        end
      rescue
        nil
      end

      def config_error(message)
        fail(JourneyWalker::Config::InvalidConfigError, message)
      end
    end
  end
end
