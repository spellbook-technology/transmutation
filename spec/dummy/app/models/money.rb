# frozen_string_literal: true

# Simulates the Money class from the Money gem
class Money
  Currency = Struct.new(:iso_code)

  attr_reader :fractional

  def initialize(fractional, currency_code)
    @fractional = fractional
    @currency_code = currency_code
  end

  def currency
    Currency.new(@currency_code)
  end
end
