# frozen_string_literal: true

class RuleBox::Facade
  attr_reader :model, :status, :data, :bucket, :errors, :steps, :executed, :_current_method
  attr_accessor :show_steps

  def initialize(**dependencies)
    errors = []
    settings.dependencies.each do |key, block|
      begin
        if dependencies.key? key
          value = dependencies[key]
          block&.call(value, errors)
        else
          errors << "missing keyword: #{key}"
        end
      rescue StandardError => e
        errors << e.message
      end
    end

    raise errors.join("\n") unless errors.empty?

    dependencies.each { |key, value| keys["current_#{key}".to_sym] = value }
    @executed = false
    @show_steps = settings.show_steps
  end

  def insert(model, **args)
    execute(:insert, model, args)
  end

  def select(model, **args)
    execute(:select, model, args)
  end

  def update(model, **args)
    execute(:update, model, args)
  end

  def delete(model, **args)
    execute(:delete, model, args)
  end

  def _current_class
    @_current_class ||=
      if model.nil?
        nil
      elsif model.is_a?(Class) || model.is_a?(Module)
        model
      elsif model.is_a?(Symbol) || model.is_a?(String)
        Object.const_get RuleBox::Util.camelize(model.to_s)
      else
        Object.const_get model.class.name
      end
  end

  def attributes
    attrs = {}
    %i[model status data bucket executed errors steps _current_method].each do |key|
      value = send key
      attrs[key] = value
    end
    attrs
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

  def method_missing(method, *parameters)
    super if parameters.empty?
    super if method.to_s.end_with? '='

    model = parameters[0]
    args = parameters[1] || {}
    execute(method, model, args)
  end

  def respond_to_missing?(method, _include_private = false)
    return false if @executed || method.to_s.end_with?('=')

    super
  end

  def execute(method, model, args = {})
    raise 'Process already executed' if @executed

    @executed = true
    @status = :green
    @bucket = RuleBox::Hash.new
    args.each { |key, value| bucket[key] = value } if args.is_a? Hash
    pre_process(method, model)
  end

  def pre_process(method, model)
    @model = model
    @_current_method = method
    class_name = _current_class
    @errors = []
    @steps = []

    add_step "{ method: #{method}, model: #{class_name}, args: #{bucket} }"
    strategies = class_name.strategies(method)&.map { |strategy| strategy.new(self) }
    unless strategies
      raise "class [#{class_name}] without mapped rules to [#{method}]'"
    end

    process(strategies)
  end

  def process(strategies)
    add_step "amount of rules #{strategies.count}"

    strategies.each do |strategy|
      add_step "executing of rule: #{strategy.class.name}."
      strategy.process

      break if status == :red
    end
  rescue Exception => e
    errors << settings.default_error_message
    @status = :red
    block = settings.resolve
    block.call(e, RuleBox::Proxy.new(self)) if block.is_a? Proc
  ensure
    add_step 'finalized the process on the facade.'
    return self
  end

  def settings
    RuleBox::Facade.settings
  end

  def add_step(value)
    new_value = "[#{DateTime.now.strftime('%FT%T.%L%:z')}] #{value}"
    puts new_value if show_steps || settings.show_steps
    steps << new_value
  end

  def marshal_dump
    instance_variables.map { |name| [name, instance_variable_get(name)] }.to_h
  end

  def marshal_load(variables)
    variables.each { |key, value| instance_variable_set(key, value) }
  end

  def keys
    @keys ||= {}
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

    private

    class Settings
      attr_reader :dependencies, :resolve
      attr_writer :default_error_message
      attr_accessor :show_steps

      def initialize
        @dependencies = {}
        @show_steps = false
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
