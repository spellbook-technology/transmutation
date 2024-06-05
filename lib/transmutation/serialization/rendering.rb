# frozen_string_literal: true

module Transmutation
  module Serialization
    module Rendering
      def render(json: nil, serialize: true, **args)
        return super(**args) unless json
        return super(json: json, **args) unless serialize

        super(**args, json: serialize(json))
      end
    end
  end
end
