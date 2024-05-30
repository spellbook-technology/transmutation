# frozen_string_literal: true

module Transmutation # rubocop:disable Style/Documentation
  using Transmutation::StringRefinements

  module Serialization # rubocop:disable Style/Documentation
    def self.included(base)
      caller_class = (base.instance_of?(Class) ? base.to_s : self.class.to_s)
      caller_namespace = caller_class.include?("::") ? caller_class.split("::").first : ""
      base.class_eval do
        @caller_namespace = caller_namespace
      end
    end

    BY_CALLER_NAMESPACE_WITH_NAMESPACE_AND_SERIALIZER = lambda do |caller, _resource_class, namespace:, serializer:|
      caller_namespace = namespace.to_s.include?("::") ? "" : get_caller_namespace(caller.class)

      converted_namespace = convert_namespace(namespace)

      converted_serializer = convert_serializer(serializer)

      serializer_name = serializer_from_resource_name(converted_serializer)

      "#{caller_namespace}::#{converted_namespace}::#{serializer_name}"
    end

    BY_RESOURCE_CALLER_NAMESPACE_WITH_NAMESPACE = lambda do |caller, resource_class, namespace:, **_|
      caller_namespace = namespace.to_s.include?("::") ? "" : get_caller_namespace(caller.class)

      converted_namespace = convert_namespace(namespace)

      serializer_name = serializer_from_resource_name(resource_class)

      "#{caller_namespace}::#{converted_namespace}::#{serializer_name}"
    end

    BY_CALLER_NAMESPACE_WITH_SERIALIZER = lambda do |caller, _resource_class, serializer:, **_|
      caller_namespace = get_caller_namespace(caller.class)

      converted_serializer = convert_serializer(serializer)

      serializer_name = serializer_from_resource_name(converted_serializer)

      "#{caller_namespace}::#{serializer_name}"
    end

    BY_RESOURCE_CALLER_NAMESPACE = lambda do |caller, resource_class, **_|
      caller_namespace = get_caller_namespace(caller.class)

      serializer_name = serializer_from_resource_name(resource_class)

      "#{caller_namespace}::#{serializer_name}"
    end

    BY_RESOURCE = lambda do |_caller, resource_class, **_|
      serializer_name = serializer_from_resource_name(resource_class)

      "::#{serializer_name}"
    end

    LOOKUP_STRATEGIES = [
      BY_CALLER_NAMESPACE_WITH_NAMESPACE_AND_SERIALIZER,
      BY_RESOURCE_CALLER_NAMESPACE_WITH_NAMESPACE,
      BY_CALLER_NAMESPACE_WITH_SERIALIZER,
      BY_RESOURCE_CALLER_NAMESPACE,
      BY_RESOURCE
    ].freeze

    def lookup_serializer(object, namespace: "", serializer: nil)
      lookup_serializer!(object, namespace: namespace, serializer: serializer)
    rescue NameError
      nil
    end

    def render(**args)
      return super(**args) unless args[:json]
      return super(**args) if args[:serialize] == false

      super(**args, json: serialize(args[:json]))
    end

    def lookup_serializer!(object, namespace: "", serializer: nil)
      LOOKUP_STRATEGIES.each do |strategy|
        return Object.const_get(strategy.call(self, object.class, namespace: namespace, serializer: serializer))
      rescue NameError
        next
      end

      raise NameError, "Serializer not found for #{object.class}"
    end

    def serialize(object, namespace: "", serializer: nil)
      unless object.respond_to?(:map)
        return lookup_serializer!(object, namespace: namespace,
                                          serializer: serializer).new(object)
      end

      object.map do |entry_object|
        lookup_serializer!(entry_object, namespace: namespace, serializer: serializer).new(entry_object)
      end
    end

    module_function

    def get_caller_namespace(base)
      base.class_eval do
        @caller_namespace
      end
    end

    def convert_namespace(namespace)
      namespace.to_s.camelcase
    end

    def convert_serializer(serializer)
      serializer.to_s.camelcase.gsub("Serializer", "")
    end

    def serializer_from_resource_name(name)
      "#{name}Serializer"
    end
  end
end
