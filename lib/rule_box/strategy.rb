# frozen_string_literal: true

module RuleBox
  class Strategy
    include RuleBox::MethodHelper

    attr_reader :facade

    delegate_methods :add_error, :current_method, :bucket, :errors, :executed, :get, :set_status, :status, :steps,
                     to: :facade

    def initialize(facade = nil)
      @facade = facade
    end

    def process
      raise 'Must implement this method'
    end

    private

    def model
      @facade.instance_variable_get :@model
    end

    class << self
      attr_reader :description

      def desc(description)
        @description = description
      end
    end
  end
end
