module AshFrame
  module Blocks
    # Blocks, our version of service objects, are an encapsulation of a single
    # point of business related logic. They provide basic parameter
    # validations, in addition to before, around and after callbacks.
    class Base
      class << self
        attr_accessor :required_args, :defaulted_args

        def required_args
          @required_args ||= []
        end

        def defaulted_args
          @defaulted_args ||= {}
        end

        def require *required, **defaulted
          self.required_args.push(required).flatten!
          self.defaulted_args.merge!(defaulted)

          setup_accessors!(*required, **defaulted)
        end

        def optional *named, **valued
          args = valued.merge named.zip([].fill(nil, 0..named.length)).to_h
          self.defaulted_args.merge!(args)

          setup_accessors!(*named, **valued)
        end

        def [] *args, **opts
          new(*args, **opts).send :run
        end

        alias_method :call, :[]

        private

        def setup_accessors! *args, **opts
          [ args, opts.keys ].flatten.each do |arg|
            attr_accessor arg
          end
        end
      end

      include AshFrame::Blocks::Errors

      include ActiveSupport::Callbacks
      define_callbacks :initialize, :logic, terminator: -> (_, result) { result == false }

      attr_accessor :result, :namespace

      def initialize *args, **opts
        @result = nil

        @_args, @_opts = args, opts

        set_attributes!

        run_callbacks :initialize do
        end
      end

      def logic
        fail NotImplementedError
      end

      protected

      def set_attributes!
        @_opts.each do |k, v|
          var = :"@#{ k }"
          instance_variable_set var, v
        end
      end

      def check_attributes!
        missing = self.class.required_args.select do |arg|
          ! instance_variable_defined? :"@#{ arg }"
        end

        fail ArgumentError, "Missing required arguments: #{ missing }" if missing.any?
      end

      def default_attributes!
        unset_variables = self.class.defaulted_args.keys - instance_variable_names.map{ |name| name.gsub(/@/,'').to_sym }

        self.class.defaulted_args.slice(*unset_variables).each do |k, v|
          v = instance_exec(&v) if v.kind_of? Proc
          instance_variable_set :"@#{ k }", v
        end
      end

      def run *args, **opts
        unless method(:logic).parameters.any?
          check_attributes!
          default_attributes!
        end

        func, args = method(:logic), []
        args = [ @_args, args, @_opts, opts ].flatten if func.parameters.any?

        run_callbacks :logic do
          begin
            self.result = func.call(*args)
          rescue => e
            add_error e
          end
        end

        self
      end
    end
  end
end
