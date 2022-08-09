# frozen_string_literal: true

require_relative '../../../lib/rule_box'
require_relative 'user'
require_relative 'rules'

class Book
  include RuleBox::Mapper
  attr_accessor :name, :age, :throws_error

  rules_of :insert,
           Rules::CheckOwner,
           Rules::CheckName
end
