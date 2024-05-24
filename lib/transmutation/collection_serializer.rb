# frozen_string_literal: true

module Transmutation
  class CollectionSerializer # rubocop:disable Style/Documentation
    include Transmutation::Serialization

    def initialize(objects, namespace: "", variant: nil)
      @objects = objects
      @namespace = namespace
      @variant = variant
    end

    def as_json(options = {})
      serializers = serialize(objects, namespace: namespace, variant: variant)

      serializers.map do |serializer|
        serializer.as_json(options)
      end
    end

    private

    attr_reader :objects, :namespace, :variant
  end
end
