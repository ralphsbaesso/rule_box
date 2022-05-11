# frozen_string_literal: true

module RuleBox
  module ExecutionHook
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      new_hooks = %i[
        after_rule after_rules around_rule around_rules
        customize_result
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

      def rescue_from(*klasses, &block)
        klasses.each do |klass|
          match = klass < Exception || klass == Exception
          raise ArgumentError, "#{klass.inspect} must be an Exception class" unless match

          rescue_handlers.concat [[klass, block]]
        end
      end

      def rescue_handlers
        @rescue_handlers ||= []
      end

      def resolve_exception!(facade)
        rescue_handlers.each do |exception, block|
          next unless facade.exception.is_a? exception

          block.call facade
          return true
        end

        nil
      end

      private

      def hooks
        @hooks ||= {}
      end
    end
  end
end
