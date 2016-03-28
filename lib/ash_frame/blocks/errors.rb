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

      def add_error message:, **opts
        errors.push opts.merge({ message: message })
      end
    end
  end
end
