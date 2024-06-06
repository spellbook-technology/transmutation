# frozen_string_literal: true

module Transmutation
  module Serialization
    module Rendering
      def render(json: nil, serialize: true, namespace: nil, serializer: nil, **args)
        return super(**args) unless json
        return super(**args, json: json) unless serialize

        super(**args, json: serialize(json, namespace: namespace, serializer: serializer))
      end
    end
  end
end
