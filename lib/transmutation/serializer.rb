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
  #   end
  class Serializer
    extend ClassAttributes

    def initialize(object)
      @object = object
    end

    def to_json(options = {})
      as_json(options).to_json
    end

    def as_json(_options = {})
      attributes_config.each_with_object({}) do |(attr_name, attr_options), hash|
        hash[attr_name.to_s] = attr_options[:block] ? instance_exec(&attr_options[:block]) : object.send(attr_name)
      end
    end

    # Define an attribute to be serialized
    #
    # @param attribute_name [Symbol] The name of the attribute to serialize
    # @param block [Proc] The block to call to get the value of the attribute.
    #   The block is called in the context of the serializer instance.
    #
    # @example
    #   class UserSerializer < Transmutation::Serializer
    #     attribute :first_name
    #
    #     attribute :full_name do
    #       "#{object.first_name} #{object.last_name}".strip
    #     end
    #   end
    def self.attribute(attribute_name, &block)
      attributes_config[attribute_name] = { block: block }
    end

    # Shorthand for defining multiple attributes
    #
    # @param attribute_names [Array<Symbol>] The names of the attributes to serialize
    #
    # @example
    #   class UserSerializer < Transmutation::Serializer
    #     attributes :first_name, :last_name
    #   end
    def self.attributes(*attribute_names)
      attribute_names.each do |attr_name|
        attribute(attr_name)
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
