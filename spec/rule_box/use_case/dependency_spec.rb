# frozen_string_literal: true

Validate = proc do |owner|
  InvalidDependency.new('owner should be a Hash') unless owner.is_a? Hash
end

class TestDependency < RuleBox::UseCase::Dependency
  add :code
  add :external, default: false
  add :repository, default: nil
  add :message, default: 'hello world'
  add :owner, validate: Validate
end

module Code
  class CheckCode < RuleBox::UseCase
    dependency do |d|
      d.add :code, validate: lambda { |value|
        InvalidDependency.new('c deve ser número') unless value.is_a?(Numeric)
      }
    end
  end

  class CheckTopCode < CheckCode
    dependency do |d|
      d.add :top_code
    end
  end
end

RSpec.describe RuleBox::UseCase::Dependency do
  context 'instance methods' do
    context '#schema' do
      it do
        dependency = TestDependency.new(code: '123', owner: { name: 'Josep' })
        expect(dependency.schema).to be_a(Hash)
        expect(dependency.schema.keys).to include('code', 'owner')
        expect(dependency.schema)
          .to eq({
                   'code' => {},
                   'external' => { 'default' => false },
                   'message' => { 'default' => 'hello world' },
                   'owner' => {},
                   'repository' => { 'default' => nil }
                 })
      end
    end

    context '#attributes' do
      it do
        dependency = TestDependency.new(code: '123', owner: { name: 'Josep' })
        expect(dependency.code).to eq('123')
        expect(dependency.external).to eq(false)
        expect(dependency.repository).to eq(nil)
        expect(dependency.message).to eq('hello world')
        expect(dependency.owner).to eq({ name: 'Josep' })
      end
    end

    context '#check_dependency!' do
      it 'return InvalidDependency Exception' do
        expect do
          TestDependency.new
        end.to raise_error(InvalidDependency)
      end

      it 'without arguments' do
        expect do
          TestDependency.new
        end.to raise_error(/(missing keyword: code)*(missing keyword: owner)/)
      end

      it 'with wrong argument' do
        expect do
          TestDependency.new(code: '456', owner: 'Raul')
        end.to raise_error('owner should be a Hash')
      end
    end
  end

  describe 'with UseCase' do
    describe '#check_dependency!' do
      it 'without arguments' do
        expect do
          Code::CheckCode.new
        end.to raise_error(/missing keyword: code/)
      end
    end
  end
end
