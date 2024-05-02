# frozen_string_literal: true

require_relative "transmutation/version"
require_relative "transmutation/serializer"
require_relative "transmutation/serialization"
require_relative "transmutation/collection_serializer"

module Transmutation
  class Error < StandardError; end
end
