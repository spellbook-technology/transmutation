# frozen_string_literal: true

module Transmutation
  module Serialization
    module Rendering
      # Serializes the value of the `json` parameter before calling the existing render method.
      #
      # Handles both Rails-style hash arguments (e.g., from send_data) and keyword arguments.
      def render(options = nil, **kwargs)
        # Handle Rails-style positional hash argument (e.g., from send_data calling render(body: data))
        if options.is_a?(Hash)
          return super(options) unless options.key?(:json)

          kwargs = options.merge(kwargs)
        end

        json = kwargs.delete(:json)
        should_serialize = kwargs.key?(:serialize) ? kwargs.delete(:serialize) : true
        namespace = kwargs.delete(:namespace)
        serializer = kwargs.delete(:serializer)
        max_depth = kwargs.delete(:max_depth) || Transmutation.max_depth
        context = kwargs.delete(:context) { self }

        return super(**kwargs) unless json
        return super(**kwargs, json:) unless should_serialize

        super(**kwargs, json: serialize(json, namespace:, serializer:, max_depth:, context:))
      end
    end
  end
end
