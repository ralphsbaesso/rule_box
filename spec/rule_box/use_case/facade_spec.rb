# frozen_string_literal: true

RSpec.describe RuleBox::UseCase::Facade do
  context 'instance methods' do
    context '#instance_values' do
      it do
        facade = RuleBox::UseCase::Facade.new
        expect(facade.instance_values).to be_a(Hash)
        expect(facade.instance_values.keys)
          .to include(:current_strategy, :strategies, :exception, :result, :steps)
      end
    end

    context '#steps' do
      it do
        facade = RuleBox::UseCase::Facade.new
        steps = facade.steps # clone
        steps << 'anything'

        expect(facade.steps).to_not eq(steps)
      end
    end
  end
end
