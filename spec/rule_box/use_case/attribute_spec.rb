# frozen_string_literal: true

module TestAttributes
  class Test < RuleBox::Strategy
    def perform
      # rule
    end
  end

  class UseCase < RuleBox::UseCase
    attributes :name, :age, :job
    rules Test
  end
end

RSpec.describe RuleBox::UseCase::Attribute do
  context 'instance methods' do
    context '#names' do
      it do
        use_case = TestAttributes::UseCase.new
        use_case.exec name: 'Jack', age: 53, job: :actor

        expect(use_case.attributes.names).to include(:name, :age, :job)
        expect(use_case.attr.names).to include(:name, :age, :job)
      end
    end
  end
end
