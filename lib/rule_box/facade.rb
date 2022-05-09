# frozen_string_literal: true

module RuleBox
  class Facade
    attr_accessor :last_result
    attr_reader :current_method, :bucket, :executed, :status

    def initialize(**dependencies)
      set_dependencies dependencies
      set_cloned_methods
      @executed = false
    end

    def exec(method = :perform, model, **args)
      perform method, model, **args
    end

    def get(key)
      keys[key.to_s].clone
    end

    def attributes
      %i[model status bucket executed errors steps current_method].map do |key|
        value = send key
        [key, value]
      end.to_h
    end

    def to_json(**args)
      JSON.generate(as_json(args), args)
    end

    def as_json(**options)
      options.key?(:root) ? { self.class.name.to_sym => attributes } : attributes
    end

    def to_s
      as_json(root: true).to_s
    end

    private

    def set_dependencies(dependencies)
      errors = []
      settings.dependencies.each do |key, block|
        if dependencies.key? key
          value = dependencies[key]
          block&.call(value, errors)
        else
          errors << "missing keyword: #{key}"
        end
      rescue StandardError => e
        errors << e.message
      end

      raise errors.join("\n") unless errors.empty?

      dependencies.each { |key, value| set key, value }
    end

    def perform(method, model, **args)
      raise 'Process already executed' if @executed

      initialize_variables!(method, model, args)
      class_strategies = load_class_strategies(method, model)
      raise "class [#{model.class}] without mapped rules to [#{method}]'" unless class_strategies

      execute_strategies(class_strategies)
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
    end

    def build_build_bucket
      {}
    end

    def start_status
      :green
    end

    def load_class_strategies(method, model)
      model.class.strategies(method)
    end

    def execute_strategies(class_strategies)
      add_step "amount of rules #{class_strategies.count}"

      class_strategies.each do |class_strategy|
        self.last_result = execute_strategy(class_strategy)
        break if status == failure_status
      end
    rescue Exception => e
      @errors << settings.default_error_message
      @status = failure_status
      block = settings.resolve
      block.call(e, clone) if block.is_a? Proc
    ensure
      add_step 'finalized the process on the facade.'
      return return_result
    end

    def execute_strategy(class_strategy)
      strategy = class_strategy.new(self)
      add_step "executing of rule: #{strategy.class.name}."
      strategy.process
    end

    def return_result
      customize = model.class.hooks[:customize_result]
      customize.is_a?(Proc) ? customize.call(self) : last_result
    end

    def failure_status
      :red
    end

    def settings
      RuleBox::Facade.settings
    end

    def add_error(msg)
      if msg.is_a? Array
        @errors.concat(msg)
      else
        @errors << msg
      end
    end

    def add_step(value)
      new_value = "[#{DateTime.now.strftime('%FT%T.%L%:z')}] #{value}"
      steps << new_value
    end

    def keys
      @keys ||= {}
    end

    def set(key, value)
      keys[key.to_s] = value
    end

    def set_status(status)
      @status = status
    end

    def cloned_objects
      %i[errors model steps]
    end

    def set_cloned_methods
      cloned_objects.each do |method|
        self.class.define_method(method) { instance_variable_get("@#{method}").clone }
      end
    end

    # class Methods
    class << self
      def configure
        yield(settings) if block_given?
      end

      def clear_configuration
        @settings = Settings.new
      end

      def settings
        @settings ||= Settings.new
      end

      class Settings
        attr_reader :dependencies, :resolve
        attr_writer :default_error_message

        def initialize
          @dependencies = {}
        end

        def add_dependency(key, &block)
          dependencies[key.to_sym] = block
        end

        def resolver_exception(&block)
          @resolve = block
        end

        def default_error_message
          @default_error_message || 'unhandled error'
        end
      end
    end
  end
end
