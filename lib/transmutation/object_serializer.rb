# frozen_string_literal: true

module Transmutation
  # Default object serializer.
  # This is used when no serializer is found for the given object.
  class ObjectSerializer < Serializer
    def as_json(options = {})
      object.as_json(options)
    end
  end
end
