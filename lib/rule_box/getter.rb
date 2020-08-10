# frozen_string_literal: true

module RuleBox::Getter
  def initialize(facade)
    raise 'Must pass an "RFacade"' unless facade.is_a? RuleBox::Facade

    @facade = facade
  end

  def model
    model = @facade.model
    if model.is_a?(Class) || model.is_a?(Module)
      model.to_s
    else
      model.clone
    end
  end

  def status
    @facade.status
  end

  def data
    @facade.data.clone
  end

  def bucket
    @facade.bucket.clone
  end

  def errors
    @facade.errors.clone
  end

  def steps
    @facade.steps.clone
  end

  def executed
    @facade.executed
  end

  def to_json(**args)
    @facade.to_json(args)
  end

  def as_json(**options)
    options.key?(:root) ? { self.class.name.to_sym => @facade.attributes } : @facade.attributes
  end

  def to_s
    @facade.as_json(root: true).to_s
  end

  def respond_to_missing?(*several_variants)
    super unless method.to_s.start_with? 'current_'
  end

  private

  def method_missing(method)
    super unless method.to_s.start_with? 'current_'

    keys = @facade.send :keys
    keys[method].clone
  end
end
