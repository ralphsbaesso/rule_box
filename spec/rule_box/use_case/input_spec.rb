# frozen_string_literal: true

module TestInputs
  class Test < RuleBox::Strategy
    def perform
      # rule
    end
  end

  class UseCase < RuleBox::UseCase
    inputs :name, :age, :job
    rules Test
  end
end

RSpec.describe RuleBox::UseCase::Input do
  context 'instance methods' do
    context '#schema' do
      it do
        use_case = TestInputs::UseCase.new
        use_case.exec name: 'Jack', age: 53, job: :actor

        expect(use_case.input.schema).to be_a(Hash)
        expect(use_case.input.schema.keys).to include('name', 'age', 'job')
      end
    end
  end
end
