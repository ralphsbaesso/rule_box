# frozen_string_literal: true

RSpec.describe RuleBox::ExecutionHook do
  context 'around_all' do
    it do
      tester = Tester.new(name: 't')
      facade = RuleBox::Facade.new
      facade.exec tester

      expect(facade.status).to eq(:red)
      expect(tester.messages).to eq(%i[before after])
    end
  end

  context 'around_each' do
    it do
      tester = Tester.new(name: 't')
      facade = RuleBox::Facade.new
      facade.exec tester

      expect(facade.status).to eq(:red)
      expect(tester.one).to eq(1)
      expect(tester.two).to eq(2)
    end
  end

  context 'before_all' do
    it do
      tester = Tester.new(name: 't')
      facade = RuleBox::Facade.new
      facade.exec tester

      expect(facade.status).to eq(:red)
      expect(tester.before_messages).to eq(%i[before after])
    end
  end

  context 'before_each' do
    it do
      tester = Tester.new(name: 't')
      facade = RuleBox::Facade.new
      facade.exec tester

      expect(facade.status).to eq(:red)
      expect(tester.before_one).to eq(1)
      expect(tester.before_two).to eq(2)
    end
  end

  context 'after_all' do
    it do
      tester = Tester.new(name: 't')
      facade = RuleBox::Facade.new
      facade.exec tester

      expect(facade.status).to eq(:red)
      expect(tester.after_messages).to eq(%i[before after])
    end
  end

  context 'after_each' do
    it do
      tester = Tester.new(name: 't')
      facade = RuleBox::Facade.new
      facade.exec tester

      expect(facade.status).to eq(:red)
      expect(tester.after_one).to eq(1)
      expect(tester.after_two).to eq(2)
    end
  end

  context 'rescue_from' do
    it 'RuntimeError' do
      tester = Tester.new(name: 't123465', throws_error: true)
      facade = RuleBox::Facade.new
      facade.exec tester

      expect(facade.status).to eq(:red)
      expect(facade.errors).to eq(['RuntimeError Error!'])
    end

    it 'StandardError' do
      tester = Tester.new(name: 't123465', throws_standard_error: true)
      facade = RuleBox::Facade.new
      facade.exec tester

      expect(facade.status).to eq(:red)
      expect(facade.errors).to eq(['Standard Error!'])
    end
  end
end
