# frozen_string_literal: true

module Transmutation
  # @api private
  class Attribute
    attr_reader :name, :options, :block, :serializer

    def initialize(name, **options, &block)
      @name = name
      @options = options
      @block = block || -> { object.send(name) }
    end

    def with_serializer(serializer)
      @serializer = serializer
      self
    end

    def as_json(_options = {})
      serializer.instance_exec(&block)
    end

    def included?
      evaluate_condition(options[:if]) && !evaluate_condition(options[:unless], default: false)
    end

    private

    def evaluate_condition(condition, default: true)
      case condition
      when Symbol
        callable = serializer.method(condition)
      when Proc
        callable = condition
      when nil
        return default
      end

      serializer.instance_exec(*([as_json] * callable.arity), &callable)
    end
  end
end
