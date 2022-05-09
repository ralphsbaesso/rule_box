# frozen_string_literal: true

module RuleBox
  module MethodHelper
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def attr_clones(*methods, to: nil)
        methods.each do |method|
          define_method(method) do
            resource = to || self
            resource.instance_variable_get("@#{method}").clone
          end
        end
      end

      def delegate_methods(*methods, to:)
        methods.each do |method|
          define_method method do |*rest, **restkey|
            object = send to
            object.send method, *rest, **restkey
          end
        end
      end
    end
  end
end
