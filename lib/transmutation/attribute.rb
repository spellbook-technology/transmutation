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

    # Stream the attribute's value under its key, without building an intermediate hash entry.
    def write(serializer, writer, options)
      push_value(writer, value(serializer, options), options)
    end
  end
end
