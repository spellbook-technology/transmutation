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

    attr_reader :attributes

    def initialize(object, depth: 0, max_depth: 1)
      @object = object
      @depth = depth
      @max_depth = max_depth

      @attributes = attributes_config.transform_values { _1.dup.with_serializer(self) }
    end

    def to_json(options = {})
      as_json(options).to_json
    end

    def as_json(options = {})
      attributes.each_with_object({}) do |(attribute_name, attribute), hash|
        hash[attribute_name.to_s] = attribute.as_json(options) if attribute.included?
      end
    end

    class << self
      # Define an attribute to be serialized
      #
      # @param attribute_name [Symbol] The name of the attribute to serialize
      # @param if [Symbol, Proc] The condition to check before serializing the attribute
      # @param unless [Symbol, Proc] The condition to check before serializing the attribute
      # @yield [object] The block to call to get the value of the attribute
      #   - The block is called in the context of the serializer instance
      #
      # @example
      #   class UserSerializer < Transmutation::Serializer
      #     attribute :first_name
      #     attribute :age, if: -> (value) { value && value >= 18 }
      #     attributes :email, :phone_number, if: :some_feature_flag
      #
      #     attribute :full_name do
      #       "#{object.first_name} #{object.last_name}".strip
      #     end
      #
      #     private
      #
      #     def some_feature_flag
      #       ENV["FEATURE_FLAG__CONTACT_DETAILS"].present?
      #     end
      #   end
      def attribute(attribute_name, if: nil, unless: nil, &block)
        attributes_config[attribute_name] = Attribute.new(attribute_name, if:, unless:, &block)
      end

      # Define an association to be serialized
      #
      # @note By default, the serializer for the association is looked up in the same namespace as the serializer
      #
      # @param association_name [Symbol] The name of the association to serialize
      # @param if [Symbol, Proc] The condition to check before serializing the attribute
      # @param unless [Symbol, Proc] The condition to check before serializing the attribute
      # @param namespace [String, Symbol, Module] The namespace to lookup the association's serializer in
      # @param serializer [String, Symbol, Class] The serializer to use for the association's serialization
      # @yield [object] The block to call to get the value of the association
      #   - The block is called in the context of the serializer instance
      #   - The return value from the block is automatically serialized
      #
      # @example
      #   class UserSerializer < Transmutation::Serializer
      #     association :posts
      #     association :comments, namespace: "Nested", serializer: "User::CommentSerializer"
      #     association :archived_posts do
      #       object.posts.archived
      #     end
      #   end
      def association(association_name, if: nil, unless: nil, namespace: nil, serializer: nil, &block)
        attributes_config[association_name] =
          Association.new(association_name, if:, unless:, namespace:, serializer:, &block)
      end

      # Shorthand for defining multiple attributes
      #
      # @param attribute_names [Array<Symbol>] The names of the attributes to serialize
      #
      # @example
      #   class UserSerializer < Transmutation::Serializer
      #     attributes :first_name, :last_name
      #   end
      def attributes(*attribute_names, **, &)
        attribute_names.each do |attribute_name|
          attribute(attribute_name, **, &)
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
      def associations(*association_names, **, &)
        association_names.each do |association_name|
          association(association_name, **, &)
        end
      end

      alias belongs_to associations
      alias has_one associations
      alias has_many associations
    end

    private

    class_attribute :attributes_config, instance_writer: false, default: {}

    attr_reader :object, :depth, :max_depth

    private_class_method def self.inherited(subclass)
      super
      subclass.attributes_config = attributes_config.dup
    end
  end
end
