# frozen_string_literal: true

module RuleBox
  class UseCase
    class Facade
      attr_reader :use_case, :exception, :strategies, :current_strategy, :result

      def initialize(use_case)
        @use_case = use_case
        @steps = []
      end

      def perform
        initialize_strategies!
        add_step "initialize { use_case: #{current_class}, rules: #{@strategies.count} }"
        execute_all
        resolve_exception!
        return_result
      end

      def instance_values
        hash = {
          current_strategy: @current_strategy&.instance_values,
          strategies: (@strategies || []).map(&:instance_values)
        }

        %i[use_case exception current_class result steps].each do |key|
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

      def around(around_method, current_method)
        hooks.each do |hook|
          hook.call_hook(around_method, use_case) do
            send(current_method)
          end
        end
      end

      def check_strategies!(class_strategies)
        raise "class [#{current_class}] without mapped rules!" if class_strategies.empty?

        classes = class_strategies.reject { |strategy| strategy < RuleBox::Strategy }
        unless classes.size.zero?
          raise "class [#{classes.map(&:name).join(', ')}] must extends RuleBox::Strategy or your subclass."
        end
      end

      def current_class
        use_case.class
      end

      def execute_all
        hooks.each { |h| h.call_hook(:before_rules, use_case) }

        if hooks.any? { |h| h.has_hook? :around_rules }
          around :around_rules, :execute_strategies
        else
          execute_strategies
        end
        hooks.each { |h| h.call_hook(:after_rules, use_case) }
      end

      def execute_one
        hooks.each { |h| h.call_hook(:before_rule, use_case) }

        if hooks.any? { |h| h.has_hook? :around_rule }
          around :around_rule, :execute_strategy
        else
          execute_strategy
        end
        hooks.each { |h| h.call_hook(:after_rule, use_case) }
      end

      def execute_strategies
        @strategies.each do |strategy|
          @current_strategy = strategy
          execute_one

          break if current_strategy.stop? || failure?
        end
      rescue Exception => e
        @exception = e
      ensure
        add_step 'finalized the process on the facade.'
      end

      def execute_strategy
        add_step "executing of rule: #{current_strategy.class.name}."

        proxy = StrategyProxy.new(current_strategy)
        @result = proxy.perform use_case, result
      end

      def failure?
        result.is_a?(RuleBox::Result) && result.status == status_error
      end

      def status_error
        'error'
      end

      def has_hook?(hook_method)
        use_case.class.has_hook? hook_method
      end

      def hooks
        [current_class, RuleBox]
      end

      def initialize_strategies!
        class_strategies = use_case.class.strategies
        check_strategies!(class_strategies)
        @strategies = class_strategies.map(&:new)
      end

      def return_result
        result
      end

      def resolve_exception!
        return unless @exception.is_a?(Exception)

        result = current_class.resolve_exception!(@exception, use_case)
        result = RuleBox.resolve_exception!(@exception, use_case) unless result.is_a? RuleBox::Result

        raise @exception unless result.is_a? RuleBox::Result

        @result = result
      end
    end
  end
end
