# frozen_string_literal: true

require 'time'
require 'json'
require 'set'

require 'rule_box/execution_hook'

module RuleBox
  include RuleBox::ExecutionHook
  class Error < StandardError; end

  class << self
    def show_mapped_classes
      RuleBox::Mapper.mapped.to_a
    end

    def configure
      block_given? ? yield(settings) : settings
    end

    private

    def settings
      self
    end
  end
end

require 'rule_box/method_helper'
require 'rule_box/facade'
require 'rule_box/mapper'
require 'rule_box/strategy'
require 'rule_box/use_case_base'
require 'rule_box/version'
