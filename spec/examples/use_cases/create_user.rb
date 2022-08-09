# frozen_string_literal: true

require_relative '../../../lib/rule_box'

module CreateUser
  class Facade < RuleBox::Facade
    use_case!
    add_dependency :current_user
  end

  class User
    attr_accessor :name, :age, :saved
  end

  class CheckName < RuleBox::Strategy
    def perform
      name = use_case.name

      if name.nil?
        add_error 'Name cannot be blank.'
        set_status :red
      elsif name.size < 4
        add_error 'Name must contain at least 4 characters.'
        set_status :red
      end
    end
  end

  class CheckAge < RuleBox::Strategy
    perform do
      age = use_case.age

      if !age.is_a? Integer
        add_error 'Age must be an "Integer".'
        set_status :red
      elsif age < 18
        add_error 'Must be over 18 years old.'
        set_status :red
      end
    end
  end

  class Builder < RuleBox::Strategy
    perform do
      user = User.new
      user.name = use_case.name
      user.age = use_case.age
      user
    end
  end

  class Save < RuleBox::Strategy
    perform do |user|
      # persist user
      user.saved = true
      user
    end
  end

  class UseCase < RuleBox::UseCaseBase
    attributes :name, :age

    rules CheckName,
          CheckAge,
          Builder,
          Save
  end
end
