# frozen_string_literal: true

require_relative 'use_case/input'
require_relative 'use_case/dependency'
require_relative 'use_case/facade'
require_relative 'use_case/output'

module RuleBox
  class UseCase
    extend RuleBox::ExecutionHook
    extend RuleBox::Mapper

    attr_reader :input, :output, :executed, :dependencies
    alias i input
    alias executed? executed
    alias dep dependencies
    alias o output

    def initialize(**args)
      @dependencies = dependency_class.new(**args)
    end

    def to_s
      names = self.class.name.split('::').reverse.join
      names.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .downcase
    end

    def exec(**args)
      check_executed!
      @input = input_class.new(**args)
      @output = output_class.new
      facade = facade_class.new
      facade.perform self
      output
    end

    def new_output!(**args)
      @output = output_class.new(**args)
    end

    private

    def check_executed!
      raise 'Process already executed' if @executed

      @executed = true
    end

    def dependency_class
      self.class::Dependency
    end

    def input_class
      self.class::Input
    end

    def facade_class
      self.class::Facade
    end

    def output_class
      self.class::Output
    end

    class << self
      def add_dependency(name, default: nil, optional: false, **options, &validate)
        self::Dependency.add_dependency(name, default: default, optional: optional, **options, &validate)
      end

      def input(name, **options)
        self::Input.data_accessor name, **options
      end

      def inputs(*names)
        names.each { |name| input(name) }
      end

      def output(name, **options, &callback)
        self::Output.data_accessor name, **options, &callback
      end

      def outputs(*names)
        names.each { |name| output(name) }
      end

      private

      def inherited(sub)
        super

        class_eval <<~M, __FILE__, __LINE__ + 1
          class ::#{sub}::Dependency < #{self}::Dependency; end
          ::#{sub}::Input.instance_variable_set(:@dependencies, #{self}::Input.schema)
        M

        class_eval <<~M, __FILE__, __LINE__ + 1
          class ::#{sub}::Facade < #{self}::Facade; end
        M

        class_eval <<~M, __FILE__, __LINE__ + 1
          class ::#{sub}::Input < #{self}::Input; end
          ::#{sub}::Input.instance_variable_set(:@__data, #{self}::Input.schema)
        M

        class_eval <<~M, __FILE__, __LINE__ + 1
          class ::#{sub}::Output < #{self}::Output; end
          ::#{sub}::Output.instance_variable_set(:@__data, #{self}::Output.schema)
        M
      end
    end
  end
end
