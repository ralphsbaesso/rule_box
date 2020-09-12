# frozen_string_literal: true

require_relative '../../lib/rule_box/strategy'

module Rules
  class CheckName < RuleBox::Strategy
    desc 'Verifica nome'
    def process
      user = model

      if user.name.nil?
        add_error 'Nome não pode ficar em branco.'
        set_status :red
      elsif user.name.size < 4
        add_error 'Nome deve conter pelo menos 4 caracteres'
        set_status :red
      end
    end
  end

  class CheckAge < RuleBox::Strategy
    def process
      user = model

      if !user.age.is_a? Integer
        add_error '"age must be an Integer"'
        set_status :red
      elsif user.age < 18
        add_error 'must be over 18 years old'
        set_status :red
      end
    end
  end

  class SaveModel < RuleBox::Strategy
    def process
      if status == :green
        # save model
      end
    end
  end

  class ThrowsError < RuleBox::Strategy
    def process
      user = model
      raise 'any thing' if user.throws_error
    end
  end

  class CheckOwner < RuleBox::Strategy
    desc 'Isso é uma descrição'
    def process
      unless current_user.name == 'Leo'
        add_error 'is not Leo'
        set_status :red
      end
    end
  end
end
