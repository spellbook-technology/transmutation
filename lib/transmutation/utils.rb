# frozen_string_literal: true

module Transmutation
  # The Transmutation module provides utility methods such as string transformations.
  #
  # @api public
  module Utils
    # Converts a string to PascalCase.
    #
    # @example
    #   string = Transmutation::Utils.to_pascal_case("test_string")
    #
    # @param
    #   input [String, Symbol] The string or symbol to be converted to PascalCase.
    # @return
    #   [String] The input converted to PascalCase.
    #
    # @api public
    def self.to_pascal_case(input)
      str = input.to_s

      return str if str.empty?
      return str.split("_").map(&:capitalize).join if str.include?("_")
      return str.split("-").map(&:capitalize).join if str.include?("-")
      return str.capitalize unless str[0] == str[0].upcase

      str
    end
  end
end
