# frozen_string_literal: true

require_relative 'use_case/facade'

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
      @dependencies = subclass('Dependency', **args)
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
      @input = subclass('Input', **args)
      @output = subclass('Output')
      @facade = facade_class.new
      @facade.perform self
      handle_output
    end

    def new_output!(**args)
      @output = subclass('Output', **args)
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

    def subclass(name, **args)
      self.class.subclass(name).new(**args)
    end

    class << self
      def subclass(name)
        __subclass[name] || (__subclass[name] = build_subclass(name))
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
        build_subclass_by_resource(resource, 'Dependency') if resource
        build_subclass_by_block('Dependency', &block) if block
        true
      end

      def input(resource = nil, &block)
        build_subclass_by_resource(resource, 'Input') if resource
        build_subclass_by_block('Input', &block) if block
        true
      end

      def output(resource = nil, &block)
        build_subclass_by_resource(resource, 'Output') if resource
        build_subclass_by_block('Output', &block) if block
        true
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

      def build_subclass_by_block(subclass_name, &block)
        subclass = subclass(subclass_name)
        block.call(subclass)
      end

      def build_subclass_by_resource(subclass, subclass_name)
        raise "resource #{subclass_name} already defined" if __subclass[subclass_name]
        raise "#{subclass} is not a subclass of #{subclass_name}" unless subclass.ancestors.map(&:to_s).include?("RuleBox::#{subclass_name}")

        build_custom_subclass(subclass, subclass_name)
      end

      def build_subclass(resource_name)
        return __subclass[resource_name] if __subclass[resource_name]

        unless self == ::RuleBox::UseCase
          class_eval <<~M, __FILE__, __LINE__ + 1
            class ::#{self}::#{resource_name} < RuleBox::#{resource_name}; end
          M
        end

        __subclass[resource_name] = const_get(resource_name)
      end

      def build_custom_subclass(subclass, subclass_name)
        class_eval <<~M, __FILE__, __LINE__ + 1
          class ::#{self}::#{subclass_name} < #{subclass}; end
          ::#{self}::#{subclass_name}.instance_variable_set(:@__data, #{subclass}.schema)
        M

        __subclass[subclass_name] = const_get(subclass_name)
      end

      def __subclass
        @__subclass ||= {}
      end
    end
  end
end
