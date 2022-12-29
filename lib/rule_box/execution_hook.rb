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

    def call_hook(type, arg = nil)
      block = hooks[type.to_sym]
      return nil unless block.is_a? Proc

      block.call(arg)
    end

    def clear_hooks!
      @rescue_handlers = []
      @hooks = {}
    end

    def has_hook?(name)
      hooks[name.to_sym].is_a? Proc
    end

    def rescue_from(*klasses, with:)
      klasses.each do |klass|
        match = klass < Exception || klass == Exception
        raise ArgumentError, "#{klass.inspect} must be an Exception class" unless match

        rescue_handlers.concat [[klass, with]]
      end
    end

    def resolve_exception!(exc, entity)
      rescue_handlers.each do |exception, method_name|
        next unless exc.is_a? exception

        method = entity.method method_name
        return method.parameters.empty? ? method.call : method.call(exc)
      end

      nil
    end

    private

    def rescue_handlers
      @rescue_handlers ||= []
    end

    def hooks
      @hooks ||= {}
    end
  end
end
