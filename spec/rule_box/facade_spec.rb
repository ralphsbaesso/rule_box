# frozen_string_literal: true

RSpec.describe RuleBox::Facade do
  context 'with validators throwing exceptions' do
    before :all do
      RuleBox::Facade.configure do |config|
        config.add_dependency(:hash) do |obj|
          raise 'Must be an Hash' unless obj.is_a?(Hash)
        end
        config.add_dependency(:array) do |obj|
          raise 'Must be an Array' unless obj.is_a?(Array)
        end
      end
    end

    after(:all) { RuleBox::Facade.clear_configuration! }

    it 'must generate one error' do
      expect { RuleBox::Facade.new }.to raise_error(RuntimeError)
    end

    it 'must generate one error on first validator' do
      expect { RuleBox::Facade.new(hash: [], array: []) }.to raise_error('Must be an Hash')
    end

    it 'must generate one error on second validator' do
      expect { RuleBox::Facade.new(hash: {}, array: 123_456) }.to raise_error('Must be an Array')
    end
  end

  context 'with validators add errors' do
    before :all do
      RuleBox::Facade.configure do |config|
        config.add_dependency :integer do |obj, errors|
          errors << 'Must pass one Integer' unless obj.is_a?(Integer)
        end
      end
    end
    after(:all) { RuleBox::Facade.clear_configuration! }

    it 'with validators add errors' do
      expect { RuleBox::Facade.new(integer: {}, array: 123_456) }.to raise_error('Must pass one Integer')
    end
  end

  context 'instance methods' do
    context '#check_strategies' do
      it 'validate if it have strategies' do
        current_class = 'MyClass'
        current_method = 'my_method'
        allow_any_instance_of(RuleBox::Facade).to receive(:current_class).and_return(current_class)
        allow_any_instance_of(RuleBox::Facade).to receive(:current_method).and_return(current_method)

        facade = RuleBox::Facade.new
        expect { facade.send(:check_strategies!, []) }
          .to raise_error("class [#{current_class}] without mapped rules to [#{current_method}]'")
      end

      it 'validate if all strategies extends RuleBox::Strategy' do
        strategy1 = Class.new(RuleBox::Strategy)
        strategy2 = Class.new(OpenStruct)
        strategy3 = Class.new(RuleBox::Strategy)

        strategies = [strategy1, strategy2, strategy3]

        facade = RuleBox::Facade.new
        expect { facade.send(:check_strategies!, strategies) }
          .to raise_error('class [] must extends RuleBox::Strategy or your subclass.')
      end
    end
  end
end
