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

    def initialize(object, depth: 0, max_depth: 1, context: nil)
      @object = object
      @depth = depth
      @max_depth = max_depth
      @context = context
    end

    def to_json(options = {})
      as_json(options).to_json
    end

    def as_json(options = {})
      fields.each_with_object({}) do |field, hash|
        hash[field.key] = field.value(self, options) if field.render?(self)
      end
    end

    class << self
      # Define an attribute to be serialized
      #
      # @param attribute_name [Symbol] The name of the attribute to serialize
      # @param if [Symbol, Proc] Only include the attribute when the condition evaluates truthy
      # @param unless [Symbol, Proc] Exclude the attribute when the condition evaluates truthy
      #   - A Symbol is sent to the serializer instance, a Proc is evaluated in its context
      # @yield [object] The block to call to get the value of the attribute
      #   - The block is called in the context of the serializer instance
      #
      # @example
      #   class UserSerializer < Transmutation::Serializer
      #     attribute :first_name
      #
      #     attribute :full_name do
      #       "#{object.first_name} #{object.last_name}".strip
      #     end
      #
      #     attribute :email, if: :admin?
      #   end
      def attribute(attribute_name, **options, &block)
        fields[attribute_name] = Attribute.new(attribute_name, **options, &block)
      end

      # Define an association to be serialized
      #
      # @note By default, the serializer for the association is looked up in the same namespace as the serializer
      #
      # @param association_name [Symbol] The name of the association to serialize
      # @param namespace [String, Symbol, Module] The namespace to lookup the association's serializer in
      # @param serializer [String, Symbol, Class] The serializer to use for the association's serialization
      # @param if [Symbol, Proc] Only include the association when the condition evaluates truthy
      # @param unless [Symbol, Proc] Exclude the association when the condition evaluates truthy
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
      def association(association_name, namespace: nil, serializer: nil, **options, &block)
        fields[association_name] = Association.new(association_name, namespace:, serializer:, **options, &block)
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

    # @return [Object] the object being serialized
    # @return [Integer] depth the current nesting depth
    # @return [Integer] max_depth the maximum nesting depth to serialize
    # @return [Object, nil] context the caller-supplied context (defaults to the caller of `serialize`)
    attr_reader :object, :depth, :max_depth, :context

    private

    class_attribute :fields, instance_accessor: false, default: {}

    # The fields declared on this serializer, in declaration order.
    def fields
      self.class.fields.values
    end

    private_class_method def self.inherited(subclass)
      super
      subclass.fields = fields.dup
    end
  end
end
