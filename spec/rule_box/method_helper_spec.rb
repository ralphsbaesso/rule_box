# frozen_string_literal: true

RSpec.describe RuleBox::MethodHelper do
  context 'class methods' do
    context '.attr_clones' do
      it 'must return cloned object' do
        errors = ['error']
        entity = { name: :entity }
        steps = [1, 2, 3]

        facade = RuleBox::Facade.new
        facade.instance_variable_set :@errors, errors
        facade.instance_variable_set :@entity, entity
        facade.instance_variable_set :@steps, steps

        expect(facade.send(:errors)).to_not be(errors)
        expect(facade.send(:entity)).to equal(entity)
        expect(facade.send(:steps)).to_not be(steps)
      end
    end
  end
end
