# frozen_string_literal: true

require 'time'
require 'json'

require 'rule_box/execution_hook'
require 'rule_box/result'
require 'rule_box/mapper'
require 'rule_box/strategy'
require 'rule_box/strategy_proxy'
require 'rule_box/use_case'
require 'rule_box/version'

module RuleBox
  extend RuleBox::ExecutionHook
  class Error < StandardError; end
end
