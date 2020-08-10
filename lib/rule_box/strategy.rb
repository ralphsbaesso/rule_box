# frozen_string_literal: true

class RuleBox::Strategy
  include RuleBox::Getter

  def process
    raise 'Must implement this method'
  end

  def set_status(status)
    @facade.instance_variable_set :@status, status
  end

  def add_error(msg)
    if msg.is_a? Array
      @facade.errors.concat(msg)
    else
      @facade.errors << msg
    end
  end

  def model
    @facade.model
  end

  def data
    @facade.data
  end

  def data=(data)
    @facade.instance_variable_set :@data, data
  end

  def bucket
    @facade.bucket
  end

  class << self
    attr_reader :description

    def desc(description)
      @description = description
    end
  end
end
