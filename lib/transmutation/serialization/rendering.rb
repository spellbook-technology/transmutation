# frozen_string_literal: true

module Transmutation
  module Serialization
    module Rendering
      # Serializes the value of the `json` parameter before calling the existing render method.
      def render(json: nil, serialize: true, namespace: nil, serializer: nil, max_depth: 1, **args)
        return super(**args) unless json
        return super(**args, json:) unless serialize

        super(**args, json: serialize(json, namespace:, serializer:, max_depth:))
      end
    end
  end
end
