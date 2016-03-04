require 'r18n-core'
require 'json-schema'
require_relative 'invalid_config_error'
require_relative '../data_source'

module JourneyWalker
  module Config
    # Runs all validations on the config file
    class ConfigValidator
      include R18n::Helpers

      def validate(config)
        @config = config
        config_schema = JSON.parse(File.read(File.join(File.dirname(File.expand_path(__FILE__)), 'config_schema.json')))
        validation_errors = JSON::Validator.fully_validate(config_schema, @config, validate_schema: true)
        config_error("\n" + validation_errors.join("\n")) unless validation_errors.empty?
        validate_data_sources(config[:data_sources]) unless config[:data_sources].nil?
        validate_transitions(config[:transitions])
      end

      private

      def validate_data_sources(data_sources_config)
        data_sources_config.each do |data_source_config|
          validate_data_source(data_source_config)
        end
      end

      def validate_data_source(data_source_config)
        data_sources = JourneyWalker::DataSource.find_data_source(data_source_config[:type])
        config_error(t.error.unknown_source_type(data_source_config[:type])) if data_sources.empty?
        data_sources[0].validate(data_source_config)
      end

      def validate_transitions(transitions_config)
        transitions_config.each do |transition|
          validate_transition(transition)
        end
      end

      def validate_transition(transition)
        validate_to(transition)
        validate_from(transition)
        validate_conditions(transition)
      end

      def validate_conditions(transition)
        conditions = transition[:conditions]
        conditions.each do |condition|
          validate_condition(condition, transition)
        end unless conditions.nil?
      end

      def validate_condition(condition, transition)
        config_error(t.error.unknown_source(condition[:source_call][:source].to_json, transition.to_json)) unless
            data_source_exists(condition[:source_call][:source]) || condition[:source_call][:source].nil?
      end

      def validate_to(transition)
        config_error(t.error.invalid_state(transition[:to])) if transition.key?(:to) && !state_exists(transition[:to])
      end

      def validate_from(transition)
        config_error(t.error.invalid_state(transition[:from])) if
            transition.key?(:from) && !state_exists(transition[:from])
      end

      def state_exists(state_name)
        @config[:states].any? { |state| state[:name] == state_name }
      end

      def data_source_exists(source_name)
        @config[:data_sources].any? { |source| source[:name] == source_name }
      end

      def config_error(message)
        raise(InvalidConfigError, message)
      end
    end
  end
end
