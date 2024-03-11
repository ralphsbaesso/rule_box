# frozen_string_literal: true

class ValidateDocument < RuleBox::Strategy
end

module TopSecret
  class ValidateDocument < RuleBox::Strategy
  end
end

RSpec.describe RuleBox::Strategy do
  describe '.description' do
    describe 'without use "desc" method' do
      it 'must return class name' do
        expect(ValidateDocument.description).to eq('validate document')
      end

      it 'must return class name' do
        expect(TopSecret::ValidateDocument.description).to eq('top secret validate document')
      end
    end

    describe 'with use "desc" method' do
      it 'must return description' do
        description = 'will validate document by client rules.'
        ValidateDocument.desc description
        expect(ValidateDocument.description).to eq(description)
      end
    end
  end
end
