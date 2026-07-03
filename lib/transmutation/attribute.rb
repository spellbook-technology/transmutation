# frozen_string_literal: true

module Transmutation
  # @api private
  #
  # A plain attribute: either a block evaluated in the serializer's context, or a method sent to the
  # serialized object.
  class Attribute < Field
    def value(serializer, _options)
      block ? serializer.instance_exec(&block) : serializer.object.send(name)
    end
  end
end
