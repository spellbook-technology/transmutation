# frozen_string_literal: true

module Transmutation
  module Serialization
    # Serialize a given object with the looked up serializer.
    #
    # @param object [Object] The object to serialize.
    # @param namespace [String, Symbol, Module] The namespace to lookup the serializer in.
    # @param serializer [String, Symbol, Class] The serializer to use.
    # @param max_depth [Integer] The maximum depth of nested associations to serialize.
    #
    # @return [Transmutation::Serializer] The serialized object. This will respond to `#as_json` and `#to_json`.
    def serialize(object, namespace: nil, serializer: nil, depth: 0, max_depth: 1)
      if object.respond_to?(:map) && !object.respond_to?(:to_hash)
        return object.map do |item|
          serialize(item, namespace:, serializer:, depth:, max_depth:)
        end
      end

      lookup_serializer(object, namespace:, serializer:)
        .new(object, depth:, max_depth:)
    end

    # Lookup the serializer for the given object.
    #
    # This calls {Transmutation::Serialization::Lookup#serializer_for} to find the serializer for the given object.
    #
    # @param object [Object] The object to lookup the serializer for.
    # @param namespace [String, Symbol, Module] The namespace to lookup the serializer in.
    # @param serializer [String, Symbol, Class] The serializer to use.
    #
    # @return [Class<Transmutation::Serializer>] The serializer for the given object.
    #
    def lookup_serializer(object, namespace: nil, serializer: nil)
      Lookup.new(self, namespace:).serializer_for(object, serializer:)
    end

    private_class_method def self.included(base)
      base.include(Rendering) if base.method_defined?(:render)
    end
  end
end
