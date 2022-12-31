# frozen_string_literal: true

module CreateUser
  class CheckName < Strategy
    def perform(use_case, _result)
      name = use_case.attr.name

      turn.neutral(errors: ["Name can't be empty!"]) if name.nil? || name.to_s.empty?
    end
  end

  class CheckEmail < Strategy
    def perform(use_case, result)
      email = use_case.attr.email

      turn.neutral(result, errors: ['Invalid email!']) unless email =~ URI::MailTo::EMAIL_REGEXP
    end
  end

  class CheckThrowAnyError < Strategy
    def perform(use_case)
      raise ThrowAnyError if use_case.bucket[:throw_error]
    end
  end

  class Create < Strategy
    def perform(use_case, result)
      errors = result.errors
      return turn.error(result) unless errors.nil? || errors.empty?

      user = User.new
      user.name = use_case.attr.name
      user.email = use_case.attr.email

      turn.success(data: user)
    end
  end

  class ThrowAnyError < StandardError; end

  class UseCase < UseCaseBase
    attributes :name, :email

    rules CheckName,
          CheckEmail,
          CheckThrowAnyError,
          Create

    rescue_from ThrowAnyError, with: :handler_error

    def handler_error
      RuleBox::Result::Error.new(errors: ['Oops, something went wrong!'])
    end
  end
end
