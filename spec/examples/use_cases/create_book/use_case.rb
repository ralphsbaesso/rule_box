# frozen_string_literal: true

module CreateBook
  class CheckCode < Strategy
    def perform(use_case)
      code = use_case.attr.code
      return unless code.nil?

      stop { RuleBox::Result::Error.new(errors: ['Invalid code.']) }
    end
  end

  class CheckOwner < Strategy
    def perform(use_case)
      return if use_case.dep.user.is_a? User

      stop { RuleBox::Result::Error.new(errors: ['"owner" must be an User!']) }
    end
  end

  class Create < Strategy
    def perform(use_case)
      book = Book.new
      book.name = use_case.attr.name
      book.code = use_case.attr.code

      RuleBox::Result::Success.new(data: book)
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
