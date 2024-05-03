# frozen_string_literal: true

require "json"

module Transmutation
  class Serializer # rubocop:disable Style/Documentation
    def initialize(object)
      @object = object
    end

    def to_json(options = {})
      as_json(options).to_json
    end

    def as_json(options = {})
      _attributes.each_with_object({}) do |(attr_name, attr_options), hash|
        hash[attr_name.to_s] = attr_options[:block] ? instance_exec(&attr_options[:block]) : object.send(attr_name)
      end
    end

    def self.attribute(attr_name, &block)
      _attributes[attr_name] = {
        block:
      }
    end

    def self.attributes(*attr_name)
      attr_name.each do |name|
        attribute(name)
      end
    end

    def self._attributes
      @@attributes ||= {}
    end

    def _attributes
      self.class._attributes
    end

    private

    attr_reader :object
  end
end
