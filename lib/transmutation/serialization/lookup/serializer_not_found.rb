# frozen_string_literal: true

module Transmutation
  module Serialization
    class Lookup
      # @api public
      class SerializerNotFound < Transmutation::Error
        attr_reader :object, :namespace, :name

        def initialize(object, namespace: nil, name: nil)
          @object = object
          @namespace = namespace
          @name = name

          super [
            "Couldn't find serializer for #{object.class.name}#{namespace.empty? ? "" : " in #{namespace}"}.",
            "Tried looking for the following classes: #{attempted_lookups}."
          ].join(" ")
        end

        private

        def attempted_lookups
          namespaces_chain.map { |namespace| [namespace, name].join("::") }.join(", ")
        end

        def namespaces_chain
          @namespaces_chain ||= begin
            namespace_parts = namespace.split("::")

            namespace_parts.filter_map.with_index do |part, index|
              [*namespace_parts[...index], part].join("::")
            end.reverse
          end
        end
      end
    end
  end
end
