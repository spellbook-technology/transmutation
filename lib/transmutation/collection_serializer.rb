# frozen_string_literal: true

module Transmutation
  class CollectionSerializer # rubocop:disable Style/Documentation
    include Transmutation::Serialization

    def initialize(objects, namespace: "")
      @objects = objects
      @namespace = namespace
    end

    def as_json(options = {})
      serializers = serialize(objects, namespace: namespace)

      serializers.map do |serializer|
        serializer.as_json(options)
      end
    end

    private

    attr_reader :objects, :namespace
  end
end
