# frozen_string_literal: true

class TestDependency < RuleBox::UseCase::Dependency
  add_dependency :code
  add_dependency :external, default: false
  add_dependency :repository, optional: true
  add_dependency :message, default: 'hello world'
  add_dependency :owner do |owner|
    'owner should be a Hash' unless owner.is_a? Hash
  end
end

module Code
  class CheckCode < RuleBox::UseCase
    add_dependency :code do |c|
      'c deve ser número' unless c.is_a?(Numeric)
    end
  end

  class CheckTopCode < CheckCode
    add_dependency :top_code
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
                   'code' => { 'optional' => false },
                   'external' => { 'default' => false, 'optional' => true },
                   'message' => { 'default' => 'hello world', 'optional' => true },
                   'owner' => { 'optional' => false },
                   'repository' => { 'optional' => true }
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

      describe 'with hierarchy' do
        it 'without arguments' do
          expect do
            Code::CheckTopCode.new
          end.to raise_error(/(missing keyword: code)/)
        end
      end
    end
  end
end
