# frozen_string_literal: true

module CreateBook
  class CheckCode < Strategy
    def perform(use_case, _result)
      code = use_case.attr.code

      Error(errors: ['Invalid code.']) if code.nil?
    end
  end

  class CheckOwner < Strategy
    def perform(use_case, _result)
      use_case.dep.user.is_a? User
    end
  end

  class Create < Strategy
    def perform(use_case, _result)
      book = Book.new
      book.name = use_case.attr.name
      book.code = use_case.attr.code

      Success(data: book)
    end
  end

  class UseCase < UseCaseBase
    attributes :name, :code

    add_dependency :user do |value|
      'Must be an "User"' unless value.is_a? User
    end

    rules CheckCode,
          CheckOwner,
          Create
  end
end
