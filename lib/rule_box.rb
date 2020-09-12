# frozen_string_literal: true

require 'time'
require 'json'

module RuleBox
  class Error < StandardError; end

  class << self

    def show_mapped_classes
      RuleBox::Mapper.mapped.to_a
    end
  end

end

require 'rule_box/facade'
require 'rule_box/getter'
require 'rule_box/hash'
require 'rule_box/mapper'
require 'rule_box/proxy'
require 'rule_box/strategy'
require 'rule_box/util'
require 'rule_box/version'
