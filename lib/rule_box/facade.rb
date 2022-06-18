# frozen_string_literal: true

module RuleBox
  class Facade
    include RuleBox::MethodHelper
    include RuleBox::ExecutionHook

    attr_reader :exception, :strategies, :current_strategy, :current_method, :bucket, :executed, :last_result, :model,
                :status

    attr_clones :errors, :steps

    def initialize(**dependencies)
      set_dependencies! dependencies
      @executed = false
    end

    def add_error(msg)
      if msg.is_a? Array
        @errors.concat(msg)
      else
        @errors << msg
      end
    end

    def exec(method = :perform, model, **args)
      perform method, model, **args
    end

    def get(key)
      keys[key.to_s].clone
    end

    def run
      return unless @next_run

      send @next_run
      true
    end

    def set_status(status)
      @status = status
    end

    private

    def add_step(value)
      new_value = "[#{DateTime.now.strftime('%FT%T.%L%:z')}] #{value}"
      steps << new_value
    end

    def around(around_method, current_method)
      @next_run = current_method
      hooks.each { |hook| hook.call_hook around_method, self }
      @next_run = nil
    end

    def build_build_bucket
      {}
    end

    def check_executed!
      raise 'Process already executed' if @executed
    end

    def check_has_strategies!
      raise "class [#{current_class}] without mapped rules to [#{current_method}]'" unless @strategies
    end

    def current_class
      model.class
    end

    def execute_all
      hooks.each { |h| h.call_hook(:before_rules, self) }

      if hooks.any? { |h| h.has_hook? :around_rules }
        around :around_rules, :execute_strategies
      else
        execute_strategies
      end
      hooks.each { |h| h.call_hook(:after_rules, self) }
    end

    def execute_one
      hooks.each { |h| h.call_hook(:before_rule, self) }

      if hooks.any? { |h| h.has_hook? :around_rule }
        around :around_rule, :execute_strategy
      else
        execute_strategy
      end
      hooks.each { |h| h.call_hook(:after_rule, self) }
    end

    def execute_strategies
      add_step "amount of rules #{@strategies.count}"

      @strategies.each do |strategy|
        @current_strategy = strategy
        execute_one
        break if status == failure_status
      end
    rescue Exception => e
      @exception = e
    ensure
      add_step 'finalized the process on the facade.'
    end

    def execute_strategy
      add_step "executing of rule: #{@current_strategy.class.name}."

      @last_result =
        if @current_strategy.respond_to? :perform_with_result
          @current_strategy.perform_with_result(@last_result)
        else
          @current_strategy.perform
        end
    end

    def failure_status
      :red
    end

    def has_hook?(hook_method)
      model.class.has_hook? hook_method
    end

    def hooks
      [current_class, self.class, RuleBox]
    end

    def initialize_variables!(method, model, args)
      @executed = true
      @model = model
      @current_method = method
      @status = start_status
      @bucket = build_build_bucket
      @steps = []
      @errors = []
      args.each { |key, value| bucket[key] = value }
      @strategies = load_strategies(method, model)
    end

    def keys
      @keys ||= {}
    end

    def load_strategies(method, model)
      model.class.strategies(method)&.map { |klass| klass.new(self) }
    end

    def perform(method, model, **args)
      check_executed!
      initialize_variables!(method, model, args)
      check_has_strategies!
      execute_all
      resolve_exception!
      return_result
    end

    def return_result
      result = nil
      hooks.each do |hook|
        result = hook.call_hook(:customize_result, self)
        break if result
      end

      result || last_result
    end

    def resolve_exception!
      return unless @exception.is_a?(Exception)

      resolved = hooks.map { |hook| hook.resolve_exception!(self) }.compact
      raise @exception if resolved.length.zero?
    end

    def set(key, value)
      keys[key.to_s] = value
    end

    def set_dependencies!(dependencies)
      self.class.set_dependencies(self, dependencies)
    end

    def start_status
      :green
    end

    # class Methods
    class << self
      def add_dependency(key, &block)
        dependencies[key.to_sym] = block
      end

      def configure(&block)
        block.call(self)
      end

      def clear_configuration!
        @dependencies = {}
        clear_hooks!
      end

      def set_dependencies(facade, dependencies)
        errors = []

        self.dependencies.each do |key, block|
          if dependencies.key? key
            value = dependencies[key]
            block&.call(value, errors)
            facade.send(:set, key, value)
          else
            errors << "missing keyword: #{key}"
          end
        rescue StandardError => e
          errors << e.message
        end

        raise errors.join("\n") unless errors.empty?
      end

      private

      def dependencies
        @dependencies ||= {}
      end
    end
  end
end
