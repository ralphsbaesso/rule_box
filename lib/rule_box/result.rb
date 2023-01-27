# frozen_string_literal: true

require_relative 'result/error'
require_relative 'result/neutral'
require_relative 'result/success'

module RuleBox
  class Result
    attr_reader :data, :errors, :meta

    def initialize(data: nil, errors: nil, meta: nil)
      @data = data.clone
      @errors = errors.clone
      @meta = meta.clone
    end

    def instance_values
      {
        'status' => status,
        'data' => data,
        'errors' => errors,
        'meta' => meta
      }
    end

    def status
      raise 'Must implement this method!'
    end

    def concat!(result, skips: nil)
      skips = [skips] unless skips.is_a?(Array)
      skips = skips.map(&:to_s)

      _concat_meta!(result.meta) unless skips.include? 'meta'
      _concat_data!(result.data) unless skips.include? 'data'
      _concat_errors!(result.errors) unless skips.include? 'errors'
    end

    def _concat_data!(data)
      _concatenate_target! :data, data
    end

    def _concat_errors!(errors)
      _concatenate_target! :errors, errors
    end

    def _concat_meta!(meta)
      _concatenate_target! :meta, meta
    end

    def _concatenate_target!(target_name, data)
      target = instance_variable_get "@#{target_name}"

      if target.is_a?(Array) && data.is_a?(Array)
        target.concat data
      elsif target.is_a?(Hash) && data.is_a?(Hash)
        target.merge! data
      elsif data && target.nil?
        instance_variable_set "@#{target_name}", data
      end
    end
  end
end
