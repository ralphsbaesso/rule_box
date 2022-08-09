# frozen_string_literal: true

module Rules
  class Strategy < RuleBox::Strategy
    def model
      entity
    end
  end

  class CheckName < Strategy
    desc 'Verifica nome'
    def perform
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

  class CheckAge < Strategy
    def perform
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

  class SaveModel < Strategy
    def perform
      if status == :green
        # save model
      end
    end
  end

  class ThrowsError < Strategy
    def perform
      user = model
      raise 'any thing' if user.throws_error
    end
  end

  class ThrowsStandardError < Strategy
    def perform
      user = model
      raise StandardError if user.throws_standard_error
    end
  end

  class CheckOwner < Strategy
    desc 'Isso é uma descrição'
    def perform
      name = get :name
      unless name == 'Leo'
        add_error 'is not Leo'
        set_status :red
      end
    end
  end
end
