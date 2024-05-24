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

    def lookup_serializer(object, namespace: "", variant: nil)
      lookup_serializer!(object, namespace: namespace, variant: variant)
    rescue NameError
      nil
    end

    def render(**args)
      return super(**args) unless args[:json]
      return super(**args) if args[:serialize] == false

      super(**args, json: serialize(args[:json]))
    end

    def lookup_serializer!(object, namespace: "", variant: nil)
      caller_namespace = get_caller_namespace(self.class)

      object_class = variant.nil? ? object.class : variant.to_s.camelcase

      begin
        return Object.const_get("#{caller_namespace}::#{object_class}Serializer") if namespace.empty?
      rescue NameError
        return Object.const_get("::#{object_class}Serializer")
      end

      converted_namespace = namespace.to_s.camelcase

      return Object.const_get("#{converted_namespace}::#{object_class}Serializer") if namespace.to_s.include?("::")

      Object.const_get("#{caller_namespace}::#{converted_namespace}::#{object_class}Serializer")
    end

    def serialize(object, namespace: "", variant: nil)
      unless object.respond_to?(:map)
        return lookup_serializer!(object, namespace: namespace,
                                          variant: variant).new(object)
      end

      object.map do |entry_object|
        lookup_serializer!(entry_object, namespace: namespace, variant: variant).new(entry_object)
      end
    end

    private

    def get_caller_namespace(base)
      base.class_eval do
        @caller_namespace
      end
    end
  end
end
