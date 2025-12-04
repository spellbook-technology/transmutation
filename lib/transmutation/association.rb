# frozen_string_literal: true

module Transmutation
  # @api private
  class Association < Attribute
    def as_json(json_options = {})
      serializer
        .serialize(super, **options.slice(:namespace, :serializer), depth: depth + 1, max_depth:)
        .as_json(json_options)
    end

    def included?
      depth + 1 <= max_depth && super
    end

    private

    def depth
      serializer.send(:depth)
    end

    def max_depth
      serializer.send(:max_depth)
    end
  end
end
