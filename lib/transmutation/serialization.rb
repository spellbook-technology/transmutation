# frozen_string_literal: true

require_relative "utils"

module Transmutation
  module Serialization # rubocop:disable Style/Documentation
    def self.lookup_serializer(object, namespace: "")
      lookup_serializer!(object, namespace)
    rescue NameError
      nil
    end

    def self.lookup_serializer!(object, namespace: "")
      return Object.const_get("::#{object.class}Serializer") if namespace.empty?

      class_name = object.class.name
      parent_module = class_name.include?("::") ? class_name.split("::").first : ""
      object_class = class_name.include?("::") ? class_name.split("::").last : object.class

      namespace = Transmutation::Utils.to_pascal_case(namespace)

      return Object.const_get("#{namespace}::#{object_class}Serializer") if namespace.include?("::")

      Object.const_get("#{parent_module}::#{namespace}::#{object_class}Serializer")
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
