# frozen_string_literal: true

module CreateBook
  class CheckCode < Strategy
    def perform(use_case)
      code = use_case.input.code
      return unless code.nil?

      stop { use_case.new_output!(status: 'error', errors: ['Invalid code.']) }
    end
  end

  class CheckOwner < Strategy
    def perform(use_case)
      return if use_case.dep.user.is_a? User

      stop { use_case.new_output!(status: 'error', errors: ['"owner" must be an User!']) }
    end
  end

  class Create < Strategy
    def perform(use_case)
      book = Book.new
      book.name = use_case.input.name
      book.code = use_case.input.code

      use_case.new_output!(status: 'ok', data: book)
    end
  end

  class UseCase < UseCaseBase
    inputs :name, :code
    outputs :data, :errors, :status

    add_dependency :user do |value|
      'Must be an "User"' unless value.is_a? User
    end

    rules CheckCode,
          CheckOwner,
          Create
  end
end
