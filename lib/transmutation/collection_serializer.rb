# frozen_string_literal: true

module Transmutation
  class CollectionSerializer # rubocop:disable Style/Documentation
    def initialize(objects)
      @objects = objects
    end

    def as_json(options = {})
      objects.map do |object|
        Transmutation::Serialization.lookup_serializer(object).new(object).as_json(options)
      end
    end

    private

    attr_reader :objects
  end
end
