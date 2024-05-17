# frozen_string_literal: true

module Transmutation
  class CollectionSerializer # rubocop:disable Style/Documentation
    def initialize(objects, caller_class)
      @objects = objects
      @caller_class = caller_class
    end

    def as_json(options = {})
      objects.map do |object|
        @caller_class.serialize(object).as_json(options)
      end
    end

    private

    attr_reader :objects, :caller_class
  end
end
