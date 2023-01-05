# frozen_string_literal: true

require_relative 'use_case/attribute'
require_relative 'use_case/dependency'
require_relative 'use_case/facade'

module RuleBox
  class UseCase
    extend RuleBox::ExecutionHook
    extend RuleBox::Mapper

    attr_reader :attributes, :executed, :dependencies
    alias attr attributes
    alias executed? executed
    alias dep dependencies

    def initialize(**args)
      @dependencies = self.class::Dependency.new(**args)
    end

    def to_s
      names = self.class.name.split('::').reverse.join
      names.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .downcase
    end

    def exec(**args, &block)
      check_executed!
      @attributes = self.class::Attribute.new(**args)
      block&.call(bucket)
      facade.perform
    end

    def bucket
      @bucket ||= {}
    end

    def facade
      @facade ||= self.class::Facade.new self
    end

    private

    def check_executed!
      raise 'Process already executed' if @executed

      @executed = true
    end

    class << self
      def attributes(*names)
        names = names.map(&:to_s)
        self::Attribute.instance_variable_set(:@attribute_names, self::Attribute.names + names)
        self::Attribute.attr_accessor(*names)
      end

      def add_dependency(key, &block)
        self::Dependency.dependencies[key.to_sym] = block
        self::Dependency.define_method(key) do
          instance_variable_get("@#{key}").clone
        end
      end

      private

      def inherited(sub)
        super

        class_eval <<~M, __FILE__, __LINE__ + 1
          class ::#{sub}::Attribute < #{self}::Attribute
            def self.attribute_names
              @attribute_names ||= #{self}::Attribute.names
            end
          end
        M

        class_eval <<~M, __FILE__, __LINE__ + 1
          class ::#{sub}::Dependency < #{self}::Dependency
            def self.dependencies
              @dependencies ||= #{self}::Dependency.dependencies.clone
            end
          end
        M

        class_eval <<~M, __FILE__, __LINE__ + 1
          class ::#{sub}::Facade < #{self}::Facade; end
        M
      end
    end
  end
end
