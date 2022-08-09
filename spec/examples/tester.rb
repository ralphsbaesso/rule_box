# frozen_string_literal: true

require_relative '../../lib/rule_box/mapper'
require_relative 'v1/rules'

class Tester < OpenStruct
  include RuleBox::Mapper

  rescue_from RuntimeError do |facade|
    facade.add_error 'RuntimeError Error!'
    facade.set_status :red
  end

  rescue_from StandardError do |facade|
    facade.add_error 'Standard Error!'
    facade.set_status :red
  end

  rules Rules::CheckName,
        Rules::ThrowsError,
        Rules::ThrowsStandardError

  around_rule do |facade|
    facade.entity.one = 1
    facade.run
    facade.entity.two = 2
  end

  around_rules do |facade|
    facade.entity.messages = [:before]
    facade.run
    facade.entity.messages << :after
  end

  before_rule do |facade|
    facade.entity.before_one = 1
    facade.entity.before_two = 2
  end

  before_rules do |facade|
    facade.entity.before_messages = [:before]
    facade.entity.before_messages << :after
  end

  after_rule do |facade|
    facade.entity.after_one = 1
    facade.entity.after_two = 2
  end

  after_rules do |facade|
    facade.entity.after_messages = [:before]
    facade.entity.after_messages << :after
  end
end
