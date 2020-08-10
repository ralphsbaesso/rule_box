# frozen_string_literal: true

class RuleBox::Hash < Hash
  def []=(key, value)
    super(key.to_sym, value)
  end

  def [](key)
    super(key.to_sym)
  end
end
