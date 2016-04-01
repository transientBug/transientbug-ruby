module AshFrame
  module Blocks
    module Errors
      extend ActiveSupport::Concern

      included do
      end

      class_methods do
      end

      def errors
        @errors ||= []
      end

      def add_error exception=nil, message: nil, **opts
        message ||= exception.message if exception.kind_of? Exception
        errors.push opts.merge({ message: message, exception: exception })
      end

      def successful?
        errors.empty?
      end
    end
  end
end
