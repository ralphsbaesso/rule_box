# frozen_string_literal: true

require_relative '../../lib/rule_box/mapper'
require_relative 'rules'

class User
  include RuleBox::Mapper
  attr_accessor :name, :age, :throws_error

  rules_of :insert,
           Rules::CheckName,
           Rules::CheckAge,
           Rules::ThrowsError,
           Rules::SaveModel

  rules_of :check, Rules::CheckName
end
