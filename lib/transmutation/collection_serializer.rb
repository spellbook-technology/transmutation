# frozen_string_literal: true

module Transmutation
  class CollectionSerializer # rubocop:disable Style/Documentation
    include Transmutation::Serialization

    def initialize(objects, namespace: "", serializer: nil)
      @objects = objects
      @namespace = namespace
      @serializer = serializer
    end

    def as_json(options = {})
      serializers = serialize(objects, namespace: namespace, serializer: serializer)

      serializers.map do |serializer|
        serializer.as_json(options)
      end
    end

    private

    attr_reader :objects, :namespace, :serializer
  end
end
