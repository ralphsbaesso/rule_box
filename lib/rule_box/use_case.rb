# frozen_string_literal: true

require_relative 'use_case/input'
require_relative 'use_case/dependency'
require_relative 'use_case/facade'
require_relative 'use_case/output'

module RuleBox
  class UseCase
    extend RuleBox::Describe
    extend RuleBox::ExecutionHook
    extend RuleBox::Mapper

    attr_reader :input, :output, :executed, :dependencies
    alias i input
    alias executed? executed
    alias dep dependencies
    alias o output

    def initialize(**args)
      @dependencies = build_subclass('Dependency', **args)
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
      @input = build_subclass('Input', **args)
      @output = build_subclass('Output')
      @facade = facade_class.new
      @facade.perform self
      handle_output
    end

    def new_output!(**args)
      @output = build_subclass('Output', **args)
    end

    def schema
      self.class.schema
    end

    private

    def check_executed!
      raise 'Process already executed' if @executed

      @executed = true
    end

    def facade_class
      self.class::Facade
    end

    def handle_output
      output.to_h
    end

    def build_subclass(name, **args)
      self.class.subclass(name).new(**args)
    end

    class << self
      def subclass(name)
        __resources[name] || (__resources[name] = build_subclass(name))
      end

      def dependencies(*names)
        dependency(&->(d) { names.each { |name| d.add(name) } })
      end

      def inputs(*names)
        input(&->(i) { names.each { |name| i.add(name) } })
      end

      def outputs(*names)
        output(&->(o) { names.each { |name| o.add(name) } })
      end

      def dependency(resource = nil, &block)
        block ? build_subclass_by_block('Dependency', &block) : build_subclass_by_resource(resource, 'Dependency')
        true
      end

      def input(resource = nil, &block)
        block ? build_subclass_by_block('Input', &block) : build_subclass_by_resource(resource, 'Input')
        true
      end

      def output(resource = nil, &block)
        block ? build_subclass_by_block('Output', &block) : build_subclass_by_resource(resource, 'Output')
        true
      end

      def build_subclass_by_block(name, &block)
        subclass = build_subclass(name)
        block.call(subclass)
      end

      def build_subclass_by_resource(resource, subclass_name)
        raise "resource #{resource} already defined" if __resources[resource]

        check_inheritance!(resource, "RuleBox::UseCase::#{subclass_name}")
        __resources[subclass_name] = resource
      end

      def schema
        {
          'description' => description,
          'inputs' => subclass('Input').schema,
          'outputs' => subclass('Output').schema,
          'dependencies' => subclass('Dependency').schema
        }
      end

      private

      def check_inheritance!(current_resource_class, resource_class)
        return if current_resource_class.ancestors.map(&:to_s).include? resource_class

        raise "#{current_resource_class} is not a subclass of #{resource_class}"
      end

      def build_subclass(resource_name)
        return const_get(resource_name) if self == ::RuleBox::UseCase

        subclasses = %w[Dependency Input Output]
        raise "Resource name \"#{resource_name}\" invalid, expected [#{subclasses.join(' ')}]" unless subclasses.include?(resource_name)

        class_eval <<~M, __FILE__, __LINE__ + 1
          class ::#{self}::#{resource_name} < RuleBox::UseCase::#{resource_name}; end
        M

        const_get(resource_name)
      end

      def __resources
        @__resources ||= {}
      end
    end
  end
end
