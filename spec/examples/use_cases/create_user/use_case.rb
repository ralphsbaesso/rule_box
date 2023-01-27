# frozen_string_literal: true

module CreateUser
  class CheckName < Strategy
    def perform(use_case)
      name = use_case.attr.name

      use_case.errors << "Name can't be empty!" if name.nil? || name.to_s.empty?
    end
  end

  class CheckEmail < Strategy
    def perform(use_case)
      email = use_case.attr.email

      use_case.errors << 'Invalid email!' unless email =~ URI::MailTo::EMAIL_REGEXP
    end
  end

  class CheckThrowAnyError < Strategy
    def perform(use_case)
      raise ThrowAnyError if use_case.throw_error
    end
  end

  class Create < Strategy
    def perform(use_case, _result)
      return RuleBox::Result::Error.new(errors: use_case.errors) unless use_case.errors.empty?

      user = User.new
      user.name = use_case.attr.name
      user.email = use_case.attr.email

      RuleBox::Result::Success.new(data: user)
    end
  end

  class ThrowAnyError < StandardError; end

  class UseCase < UseCaseBase
    attributes :name, :email
    attr_accessor :throw_error

    rules CheckName,
          CheckEmail,
          CheckThrowAnyError,
          Create

    rescue_from ThrowAnyError, with: :handler_error

    def errors
      @errors ||= []
    end

    def handler_error
      RuleBox::Result::Error.new(errors: ['Oops, something went wrong!'])
    end
  end
end
