# frozen_string_literal: true

require_relative '../../lib/rule_box/mapper'
require_relative 'rules'

class Book
  include RuleBox::Mapper
  attr_accessor :name, :age, :throws_error

  puts :in_book
  rules_of_insert Rules::CheckOwner,
                  Rules::CheckName
end
