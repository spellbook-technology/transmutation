# frozen_string_literal: true

module Transmutation
  # Base class for your serializers.
  #
  # @example Basic usage
  #   class UserSerializer < Transmutation::Serializer
  #     attributes :first_name, :last_name
  #
  #     attribute :full_name do
  #       "#{object.first_name} #{object.last_name}".strip
  #     end
  #
  #     belongs_to :organization
  #
  #     has_many :posts
  #   end
  class Serializer
    extend ClassAttributes

    include Transmutation::Serialization

    def initialize(object, depth: 0, max_depth: 1)
      @object = object
      @depth = depth
      @max_depth = max_depth
    end

    def to_json(options = {})
      as_json(options).to_json
    end

    def as_json(options = {})
      attributes_config.each_with_object({}) do |(attr_name, attr_options), hash|
        if attr_options[:association]
          hash[attr_name.to_s] = instance_exec(&attr_options[:block]).as_json(options) if @depth + 1 <= @max_depth
        else
          hash[attr_name.to_s] = attr_options[:block] ? instance_exec(&attr_options[:block]) : object.send(attr_name)
        end
      end
    end

    class << self
      # Define an attribute to be serialized
      #
      # @param attribute_name [Symbol] The name of the attribute to serialize
      # @param block [Proc] The block to call to get the value of the attribute
      #   - The block is called in the context of the serializer instance
      #
      # @example
      #   class UserSerializer < Transmutation::Serializer
      #     attribute :first_name
      #
      #     attribute :full_name do
      #       "#{object.first_name} #{object.last_name}".strip
      #     end
      #   end
      def attribute(attribute_name, &block)
        attributes_config[attribute_name] = { block: block }
      end

      # Define an association to be serialized
      #
      # @note By default, the serializer for the association is looked up in the same namespace as the serializer
      #
      # @param association_name [Symbol] The name of the association to serialize
      # @param namespace [String, Symbol, Module] The namespace to lookup the association's serializer in
      # @param serializer [String, Symbol, Class] The serializer to use for the association's serialization
      #
      # @example
      #   class UserSerializer < Transmutation::Serializer
      #     association :posts
      #     association :comments, namespace: "Nested", serializer: "User::CommentSerializer"
      #   end
      def association(association_name, namespace: nil, serializer: nil)
        block = lambda do
          serialize(object.send(association_name), namespace: namespace, serializer: serializer, depth: @depth + 1, max_depth: @max_depth)
        end

        attributes_config[association_name] = { block: block, association: true }
      end

      alias belongs_to association
      alias has_one association
      alias has_many association

      # Shorthand for defining multiple attributes
      #
      # @param attribute_names [Array<Symbol>] The names of the attributes to serialize
      #
      # @example
      #   class UserSerializer < Transmutation::Serializer
      #     attributes :first_name, :last_name
      #   end
      def attributes(*attribute_names)
        attribute_names.each do |attribute_name|
          attribute(attribute_name)
        end
      end

      # Shorthand for defining multiple associations
      #
      # @param association_names [Array<Symbol>] The names of the associations to serialize
      #
      # @example
      #   class UserSerializer < Transmutation::Serializer
      #     associations :posts, :comments
      #   end
      def associations(*association_names)
        association_names.each do |association_name|
          association(association_name)
        end
      end
    end

    private

    class_attribute :attributes_config, instance_writer: false, default: {}

    attr_reader :object

    private_class_method def self.inherited(subclass)
      super
      subclass.attributes_config = attributes_config.dup
    end
  end
end
