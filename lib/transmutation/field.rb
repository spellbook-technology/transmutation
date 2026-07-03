# frozen_string_literal: true

module Transmutation
  # @api private
  #
  # Base class for a serializable field. Encapsulates the name, the precomputed JSON key, and the
  # optional `if:`/`unless:` rendering conditions shared by attributes and associations.
  class Field
    attr_reader :name, :key

    def initialize(name, **options, &block)
      @name = name
      @key = name.to_s.freeze
      @block = block
      @if = options[:if]
      @unless = options[:unless]
    end

    # Whether this field should be rendered for the given serializer instance.
    def render?(serializer)
      return false if @if && !evaluate(@if, serializer)
      return false if @unless && evaluate(@unless, serializer)

      true
    end

    private

    attr_reader :block

    # A Symbol condition is sent to the serializer; anything else (e.g. a Proc) runs in its context.
    def evaluate(condition, serializer)
      condition.is_a?(Symbol) ? serializer.send(condition) : serializer.instance_exec(&condition)
    end
  end
end
