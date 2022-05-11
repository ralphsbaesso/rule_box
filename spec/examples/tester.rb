# frozen_string_literal: true

require_relative '../../lib/rule_box/mapper'
require_relative 'rules'

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
    facade.model.one = 1
    facade.run
    facade.model.two = 2
  end

  around_rules do |facade|
    facade.model.messages = [:before]
    facade.run
    facade.model.messages << :after
  end

  before_rule do |facade|
    facade.model.before_one = 1
    facade.model.before_two = 2
  end

  before_rules do |facade|
    facade.model.before_messages = [:before]
    facade.model.before_messages << :after
  end

  after_rule do |facade|
    facade.model.after_one = 1
    facade.model.after_two = 2
  end

  after_rules do |facade|
    facade.model.after_messages = [:before]
    facade.model.after_messages << :after
  end
end
