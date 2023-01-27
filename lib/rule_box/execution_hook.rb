# frozen_string_literal: true

module RuleBox
  module ExecutionHook
    new_hooks = %i[
      after_rule after_rules
      around_rule around_rules
      before_rule before_rules
    ]

    new_hooks.each do |rule|
      define_method rule do |&block|
        hooks[rule] = block
      end
    end

    def call_hook(type, arg = nil, &params_block)
      block = hooks[type.to_sym]
      return nil unless block.is_a? Proc

      block.call(arg, &params_block)
    end

    def clear_hooks!
      @rescue_handlers = []
      @hooks = {}
    end

    def hook?(name)
      hooks[name.to_sym].is_a? Proc
    end

    def handling_for_exception?(exception)
      rescue_handlers.any? do |class_error, _|
        exception.is_a? class_error
      end
    end

    def rescue_from(*klasses, with: nil, &block)
      raise 'Must pass method name or block to handler the exception' if with.nil? && block.nil?

      klasses.each do |klass|
        match = klass < Exception || klass == Exception
        raise ArgumentError, "#{klass.inspect} must be an Exception class" unless match

        rescue_handlers.concat [[klass, with || block]]
      end
    end

    def resolve_exception!(exception, entity)
      rescue_handlers.each do |exception_class, args|
        next unless exception.is_a? exception_class

        result =
          if args.is_a? Proc
            invoke_proc(entity, args)
          else
            invoke_method(entity, args, exception)
          end

        return result if result
      end

      nil
    end

    private

    def invoke_method(entity, method_name, exception)
      method = entity.method method_name
      if method.parameters.empty?
        method.call
      else
        method.call(exception)
      end
    end

    def invoke_proc(entity, block)
      block.call entity
    end

    def rescue_handlers
      @rescue_handlers ||= []
    end

    def hooks
      @hooks ||= {}
    end
  end
end
