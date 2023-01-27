# frozen_string_literal: true

module TestDependency
  class UseCase < RuleBox::UseCase
    add_dependency :code
    add_dependency :owner do |owner|
      'owner should be a Hash' unless owner.is_a? Hash
    end
  end
end

RSpec.describe RuleBox::UseCase::Dependency do
  context 'instance methods' do
    context '#names' do
      it do
        use_case = TestDependency::UseCase.new(code: '123', owner: { name: 'Josep' })
        expect(use_case.dependencies.names).to include(:code, :owner)
      end
    end

    context '#check_dependency!' do
      it 'without arguments' do
        expect do
          TestDependency::UseCase.new
        end.to raise_error(/(missing keyword: code)*(missing keyword: owner)/)
      end

      it 'with wrong argument' do
        expect do
          TestDependency::UseCase.new(code: '456', owner: 'Raul')
        end.to raise_error('owner should be a Hash')
      end
    end
  end
end
