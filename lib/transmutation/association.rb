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
      serialized(serializer).as_json(options)
    end

    # Stream the association under its key: nested serializers write themselves into the same
    # writer instead of materialising intermediate hashes.
    def write(serializer, writer, options)
      write_serialized(writer, serialized(serializer), options, key)
    end

    private

    def serialized(serializer)
      target = block ? serializer.instance_exec(&block) : serializer.object.send(name)

      serializer.serialize(
        target,
        namespace: @namespace,
        serializer: @serializer,
        depth: serializer.depth + 1,
        max_depth: serializer.max_depth,
        context: serializer.context
      )
    end

    def write_serialized(writer, serialized, options, key = nil)
      if serialized.is_a?(Array)
        writer.push_array(key)
        serialized.each { |item| write_serialized(writer, item, options) }
        writer.pop
      else
        writer.push_key(key) if key
        serialized.write_json(writer, options)
      end
    end
  end
end
