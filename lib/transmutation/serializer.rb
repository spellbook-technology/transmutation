# frozen_string_literal: true

module Transmutation
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

    def self.attribute(attr_name, &block)
      attributes_config[attr_name] = { block: block }
    end

    def self.attributes(*attr_name)
      attr_name.each do |name|
        attribute(name)
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
