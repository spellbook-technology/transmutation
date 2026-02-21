# frozen_string_literal: true

module Transmutation
  module Serialization
    class Lookup
      # @api public
      class SerializerNotFound < Transmutation::Error
        attr_reader :object, :namespace, :name

        def initialize(object, namespace: nil, name: nil)
          @object = object
          @namespace = namespace.to_s
          @name = name

          super [
            "Couldn't find serializer for #{object.class.name}#{@namespace.empty? ? "" : " in #{@namespace}"}.",
            "Tried looking for the following classes: #{attempted_lookups}."
          ].join(" ")
        end

        private

        def attempted_lookups
          namespaces_chain.map { |ns| [ns, name].join("::") }.join(", ")
        end

        def namespaces_chain
          @namespaces_chain ||= begin
            namespace_parts = namespace.split("::")

            namespace_parts.each_with_index.filter_map do |part, index|
              namespace_parts.first(index + 1).join("::")
            end.reverse
          end
        end
      end
    end
  end
end
