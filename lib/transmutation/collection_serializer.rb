# frozen_string_literal: true

module Transmutation
  # Out-of-the-box collection serializer.
  #
  # This serializer will be used to serialize all collections of objects.
  #
  # @example Basic usage
  #   Transmutation::CollectionSerializer.new([object, object]).to_json
  class CollectionSerializer
    include Transmutation::Serialization

    def initialize(objects, namespace: nil, serializer: nil)
      @objects = objects
      @namespace = namespace
      @serializer = serializer
    end

    def as_json(options = {})
      objects.map { |item| serialize(item, namespace: namespace, serializer: serializer).as_json(options) }
    end

    def to_json(options = {})
      as_json(options).to_json
    end

    private

    attr_reader :objects, :namespace, :serializer
  end
end
