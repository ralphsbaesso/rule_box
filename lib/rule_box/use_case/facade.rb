# frozen_string_literal: true

module RuleBox
  class UseCase
    class Facade
      attr_reader :exception, :strategies, :current_strategy, :result

      def initialize
        @steps = []
      end

      def perform(use_case)
        initialize_strategies! use_case
        add_step "initialize { use_case: #{use_case.class.name}, rules: #{@strategies.count} }"
        execute_all(use_case)
        resolve_exception!(use_case)
        return_result
      end

      def instance_values
        hash = {
          current_strategy: @current_strategy&.instance_values,
          strategies: (@strategies || []).map(&:instance_values)
        }

        %i[exception result steps].each do |key|
          hash[key] = send(key).clone
        end

        hash
      end

      def steps
        @steps.clone
      end

      private

      def add_step(value)
        new_value = "[#{DateTime.now.strftime('%FT%T.%L%:z')}] #{value}"
        @steps << new_value
      end

      def around(around_method, current_method, use_case)
        hooks(use_case).each do |hook|
          hook.call_hook(around_method, use_case) do
            send(current_method, use_case)
          end
        end
      end

      def check_strategies!(use_case, class_strategies)
        raise "class [#{use_case.class}] without mapped rules!" if class_strategies.empty?

        classes = class_strategies.reject { |strategy| strategy < RuleBox::Strategy }
        return if classes.size.zero?

        raise "class [#{classes.map(&:name).join(', ')}] must extends RuleBox::Strategy or your subclass."
      end

      def execute_all(use_case)
        hooks(use_case).each { |h| h.call_hook(:before_rules, use_case) }

        if hooks(use_case).any? { |h| h.has_hook? :around_rules }
          around :around_rules, :execute_strategies, use_case
        else
          execute_strategies(use_case)
        end
        hooks(use_case).each { |h| h.call_hook(:after_rules, use_case) }
      end

      def execute_one(use_case)
        hooks(use_case).each { |h| h.call_hook(:before_rule, use_case) }

        if hooks(use_case).any? { |h| h.has_hook? :around_rule }
          around :around_rule, :execute_strategy, use_case
        else
          execute_strategy(use_case)
        end
        hooks(use_case).each { |h| h.call_hook(:after_rule, use_case) }
      end

      def execute_strategies(use_case)
        @strategies.each do |strategy|
          @current_strategy = strategy
          execute_one(use_case)

          break if stop?(current_strategy)
        end
      rescue Exception => e
        @exception = e
      ensure
        add_step 'finalized the process on the facade.'
      end

      def stop?(strategy)
        strategy.stop? || exception?
      end

      def exception?
        @exception
      end

      def execute_strategy(use_case)
        add_step "executing of rule: #{current_strategy.class.name}."

        proxy = StrategyProxy.new(current_strategy)
        @result = proxy.perform use_case, result
      end

      def hooks(use_case)
        [use_case.class, RuleBox]
      end

      def initialize_strategies!(use_case)
        class_strategies = use_case.class.strategies
        check_strategies!(use_case, class_strategies)
        @strategies = class_strategies.map(&:new)
      end

      def return_result
        result
      end

      def resolve_exception!(use_case)
        return unless @exception.is_a?(Exception)

        @result =
          if use_case.class.handling_for_exception?(@exception)
            use_case.class.resolve_exception!(@exception, use_case)
          elsif RuleBox.handling_for_exception?(@exception)
            RuleBox.resolve_exception!(@exception, use_case)
          else
            raise @exception
          end
      end
    end
  end
end
