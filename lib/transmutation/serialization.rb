# frozen_string_literal: true

module Transmutation # rubocop:disable Style/Documentation
  using Transmutation::StringRefinements
  module Serialization # rubocop:disable Style/Documentation
    def self.included(base)
      base.extend(ClassMethods)
    end

    def render(**args)
      return super(**args) unless args[:json]
      return super(**args) if args[:serialize] == false

      if args[:json].respond_to?(:map)
        return super(**args, json: Transmutation::CollectionSerializer.new(args[:json],
                                                                           self.class))
      end

      super(**args, json: self.class.serialize(args[:json]))
    end

    def self.lookup_serializer!(*args, **kwargs)
      ClassMethods.lookup_serializer!(*args, **kwargs)
    end

    def self.lookup_serializer(*args, **kwargs)
      ClassMethods.lookup_serializer(*args, **kwargs)
    end

    def self.serialize(object, **kwargs)
      ClassMethods.serialize(object, **kwargs)
    end

    module ClassMethods # rubocop:disable Style/Documentation
      def self.extended(base)
        caller_class = (base.instance_of?(Class) ? base.to_s : self.class.to_s)
        caller_namespace = caller_class.include?("::") ? caller_class.split("::").first : ""
        base.instance_variable_set(:@caller_namespace, caller_namespace)
      end

      def lookup_serializer(object, namespace: "")
        lookup_serializer!(object, namespace: namespace)
      rescue NameError
        nil
      end

      def lookup_serializer!(object, namespace: "")
        caller_namespace = instance_variable_get(:@caller_namespace)
        puts caller_namespace, object.class, namespace

        return Object.const_get("#{caller_namespace}::#{object.class}Serializer") if namespace.empty?

        converted_namespace = namespace.to_s.camelcase

        return Object.const_get("#{converted_namespace}::#{object.class}Serializer") if namespace.to_s.include?("::")

        Object.const_get("#{caller_namespace}::#{converted_namespace}::#{object.class}Serializer")
      end

      def serialize(object, namespace: "")
        lookup_serializer!(object, namespace: namespace).new(object)
      end

      private

      def caller_namespace
        instance_variable_get(:@caller_namespace)
      end
    end
  end
end
