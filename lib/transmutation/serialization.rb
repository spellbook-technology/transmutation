# frozen_string_literal: true

module Transmutation
  module Serialization
    # Serialize a given object with the looked up serializer.
    #
    #
    # @param object [Object] The object to serialize.
    # @param namespace [String, Symbol, Module] The namespace to lookup the serializer in.
    # @param serializer [String, Symbol, Class] The serializer to use.
    #
    # @return [Transmutation::Serializer] The serialized object. This will respond to `#as_json` and `#to_json`.
    def serialize(object, namespace: nil, serializer: nil)
      if object.respond_to?(:map)
        return object.map { |item| serialize(item, namespace: namespace, serializer: serializer) }
      end

      lookup_serializer(object, namespace: namespace, serializer: serializer).new(object)
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
      Lookup.new(self, namespace: namespace).serializer_for(object, serializer: serializer)
    end

    private_class_method def self.included(base)
      base.include(Rendering) if base.method_defined?(:render)
    end
  end
end
