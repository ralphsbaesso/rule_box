# frozen_string_literal: true

module CreateUser
  class CheckName < Strategy
    def perform(use_case)
      name = use_case.input.name

      use_case.errors << "Name can't be empty!" if name.nil? || name.to_s.empty?
    end
  end

  class CheckEmail < Strategy
    def perform(use_case)
      email = use_case.input.email

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
      unless use_case.errors.empty?
        use_case.new_output!(
          errors: use_case.errors,
          status: 'error'
        )
        return
      end

      user = User.new
      user.name = use_case.input.name
      user.email = use_case.input.email

      use_case.new_output!(data: user, status: :success)
    end
  end

  class FakerLog < Strategy
    def perform
      # log
    end
  end

  class ThrowAnyError < StandardError; end

  class UseCase < UseCaseBase
    inputs :name, :email
    outputs :data, :status, :errors
    attr_accessor :throw_error

    rules CheckName,
          CheckEmail,
          CheckThrowAnyError,
          Create,
          FakerLog

    rescue_from ThrowAnyError, with: :handler_error

    def errors
      @errors ||= []
    end

    def handler_error
      new_output!(status: :error, errors: ['Oops, something went wrong!'])
    end

    class Output
      def status
        status = read_attribute :status
        status&.to_s
      end
    end
  end
end
