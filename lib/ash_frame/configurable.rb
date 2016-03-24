module AshFrame
  module Configurable
    extend ::ActiveSupport::Concern

    included do
    end

    class_methods do
      # Provides the current config container
      #
      # @return [OpenStruct]
      def config
        @_config ||= OpenStruct.new
      end

      # Class level DSL for setting up default configs
      #
      # @example
      #   class MyClass
      #     include AshFrame::Configurable
      #
      #     set_config :redism 'wat'
      #   end
      #
      def set_config key, default=nil, &block
        default = _config_for(&block) if block_given?

        default = default.call if default.kind_of? Proc

        config[key] = default
      end

      # Yields the configuration
      #
      # @example
      #   MyClass.configure do |config|
      #     config.redis = 'WATMAN '
      #   end
      def configure
        yield config if block_given?
      end

      private

      # Allow nested configurations
      def _config_for &block
        klass = Class.new{ include AshFrame::Configurable }
        klass.instance_eval(&block)
        klass.config
      end
    end
  end
end
