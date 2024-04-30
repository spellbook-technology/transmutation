# frozen_string_literal: true

require "json"

module Transmutation
  class Base # rubocop:disable Style/Documentation
    @@attributes = {} # rubocop:disable Style/ClassVars

    def initialize(object)
      @object = object
    end

    def to_json(options = {})
      as_json(options).to_json
    end

    def as_json(options = {})
      @@attributes.each_with_object({}) do |(attr_name, attr_options), hash|
        hash[attr_name] = attr_options[:block] ? instance_exec(&attr_options[:block]) : object.send(attr_name)
      end
    end

    def self.attribute(attr_name, &block)
      @@attributes[attr_name] = {
        block:
      }
    end

    def self.attributes(*attr_name)
      attr_name.each do |name|
        attribute(name)
      end
    end

    private

    attr_reader :object
  end
end
