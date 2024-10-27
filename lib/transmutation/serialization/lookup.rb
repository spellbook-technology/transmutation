# frozen_string_literal: true

module Transmutation
  module Serialization
    # @api private
    class Lookup
      def initialize(caller, namespace: nil)
        @caller = caller
        @namespace = namespace
      end

      # Bubbles up the namespace until we find a matching serializer.
      #
      # @see Transmutation::Serialization#lookup_serializer
      # @note This never bubbles up the object's namespace, only the caller's namespace.
      #
      # @example
      #   namespace: Api::V1::Admin::Detailed
      #   serializer: Chat::User
      #
      #   This method will attempt to find a serializer defined in the following order:
      #
      #   - Api::V1::Admin::Detailed::Chat::UserSerializer
      #   - Api::V1::Admin::Chat::UserSerializer
      #   - Api::V1::Chat::UserSerializer
      #   - Api::Chat::UserSerializer
      #   - Chat::UserSerializer
      def serializer_for(object, serializer: nil)
        serializer_name = serializer_name_for(object, serializer:)

        return constantize_serializer!(Object, serializer_name, object:) if serializer_name.start_with?("::")

        potential_namespaces.each do |potential_namespace|
          return potential_namespace.const_get(serializer_name) if potential_namespace.const_defined?(serializer_name)
        end

        Transmutation::ObjectSerializer
      end

      # Returns the highest specificity serializer name for the given object.
      #
      # @param object [Object] The object to find the serializer name for.
      #
      # @return [String] The serializer name.
      def serializer_name_for(object, serializer: nil)
        "#{serializer&.delete_suffix("Serializer") || object.class.name}Serializer"
      end

      private

      def potential_namespaces
        @potential_namespaces ||= begin
          namespace_parts = serializer_namespace.split("::")

          namespaces = namespace_parts.filter_map.with_index do |part, index|
            namespace = [*namespace_parts[...index], part].join("::")

            next if namespace.empty?

            Object.const_get(namespace) if Object.const_defined?(namespace)
          end

          [*namespaces.reverse, Object]
        end
      end

      def serializer_namespace
        return caller_namespace if @namespace.nil?
        return @namespace       if @namespace.start_with?("::")

        "#{caller_namespace}::#{@namespace}"
      end

      def caller_namespace
        @caller_namespace ||= @caller.class.name.split("::")[...-1].join("::")
      end

      def constantize_serializer!(namespace, name, object:)
        raise SerializerNotFound.new(object, namespace:, name:) unless namespace.const_defined?(name)

        namespace.const_get(name)
      end
    end
  end
end
