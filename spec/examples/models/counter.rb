# frozen_string_literal: true

class Counter
  attr_reader :amount, :step

  def initialize
    @amount = 0
    @step = 0
  end

  def increment(value)
    @step += 1
    @amount += value
  end
end
