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
        next if attr_options[:conditional] && !render_field?(attr_options)
        next if attr_options[:association] && @depth + 1 > @max_depth

        hash[attr_name.to_s] = field_value(attr_name, attr_options, options)
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
        attributes_config[attribute_name] = field_config({ block: }, options)
      end

      # Define an association to be serialized
      #
      # @note By default, the serializer for the association is looked up in the same namespace as the serializer
      #
      # @param association_name [Symbol] The name of the association to serialize
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
      def association(association_name, namespace: nil, serializer: nil, **options, &custom_block)
        block = lambda do
          association_instance = custom_block ? instance_exec(&custom_block) : object.send(association_name)

          serialize(association_instance, namespace:, serializer:, depth: @depth + 1, max_depth: @max_depth)
        end

        attributes_config[association_name] = field_config({ block:, association: true }, options)
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

      private

      # Merge conditional rendering options into a field's config.
      #
      # The `:conditional` flag lets {#as_json} skip condition evaluation entirely for fields that
      # don't declare `if:`/`unless:`, keeping the common path a single hash lookup.
      def field_config(config, options)
        return config unless options[:if] || options[:unless]

        config.merge(if: options[:if], unless: options[:unless], conditional: true)
      end
    end

    private

    class_attribute :attributes_config, instance_writer: false, default: {}

    attr_reader :object

    # Resolve the value for a field: a serialized association, a block result, or a method call.
    def field_value(attr_name, attr_options, options)
      return instance_exec(&attr_options[:block]).as_json(options) if attr_options[:association]
      return instance_exec(&attr_options[:block]) if attr_options[:block]

      object.send(attr_name)
    end

    # Evaluate the `if:`/`unless:` conditions for a field.
    #
    # Only called for fields flagged `:conditional`, so unconditional fields incur no overhead.
    def render_field?(attr_options)
      return false if attr_options[:if] && !evaluate_condition(attr_options[:if])
      return false if attr_options[:unless] && evaluate_condition(attr_options[:unless])

      true
    end

    # A Symbol condition is sent to the serializer; a Proc (or other callable) is run in its context.
    def evaluate_condition(condition)
      condition.is_a?(Symbol) ? send(condition) : instance_exec(&condition)
    end

    private_class_method def self.inherited(subclass)
      super
      subclass.attributes_config = attributes_config.dup
    end
  end
end
