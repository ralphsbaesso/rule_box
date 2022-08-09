# frozen_string_literal: true

module RuleBox
  class UseCaseBase
    include RuleBox::Mapper

    def initialize(**args)
      args.each do |key, value|
        key = key.to_s
        attributes[key] = value if attribute_names.include? key
      end
    end

    def to_s
      names = self.class.name.split('::').reverse.join
      names.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .downcase
    end

    def attribute_names
      []
    end

    def attributes
      @attributes ||= {}
    end

    class << self
      def attributes(*names)
        names = names.map(&:to_s)
        define_method(:attribute_names) { names }

        names.each do |name|
          define_method(name) { attributes[name] }
          define_method("#{name}=") { |value| attributes[name] = value }
        end
      end
    end
  end
end
