# frozen_string_literal: true

module Transmutation
  module Serialization # rubocop:disable Style/Documentation
    def self.lookup_serializer(object)
      lookup_serializer!(object)
    rescue NameError
      nil
    end

    def self.lookup_serializer!(object)
      Object.const_get("::#{object.class}Serializer")
    end

    def self.serialize(object)
      lookup_serializer!(object).new(object)
    end

    def render(**args)
      return super(**args) unless args[:json]
      return super(**args) if args[:serialize] == false

      return super(**args, json: Transmutation::CollectionSerializer.new(args[:json])) if args[:json].respond_to?(:map)

      super(**args, json: Transmutation::Serialization.serialize(args[:json]))
    end
  end
end
