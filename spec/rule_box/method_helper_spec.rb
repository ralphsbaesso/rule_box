# frozen_string_literal: true

RSpec.describe RuleBox::MethodHelper do
  context 'class methods' do
    context '.attr_clones' do
      it 'must return cloned object' do
        errors = ['error']
        model = { name: :model }
        steps = [1, 2, 3]

        facade = RuleBox::Facade.new
        facade.instance_variable_set :@errors, errors
        facade.instance_variable_set :@model, model
        facade.instance_variable_set :@steps, steps

        expect(facade.send(:errors)).to_not be(errors)
        expect(facade.send(:model)).to_not equal(model)
        expect(facade.send(:steps)).to_not be(steps)
      end
    end
  end
end
