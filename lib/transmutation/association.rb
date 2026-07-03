# frozen_string_literal: true

module Transmutation
  # @api private
  #
  # An association: resolves the associated object (via a block or a method on the object) and
  # serializes it with the looked up serializer, one level deeper. Only rendered within `max_depth`.
  class Association < Field
    def initialize(name, namespace: nil, serializer: nil, **options, &block)
      super(name, **options, &block)

      @namespace = namespace
      @serializer = serializer
    end

    def render?(serializer)
      super && serializer.depth < serializer.max_depth
    end

    def value(serializer, options)
      target = block ? serializer.instance_exec(&block) : serializer.object.send(name)

      serializer.serialize(
        target,
        namespace: @namespace,
        serializer: @serializer,
        depth: serializer.depth + 1,
        max_depth: serializer.max_depth,
        context: serializer.context
      ).as_json(options)
    end
  end
end
