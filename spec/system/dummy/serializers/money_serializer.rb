# frozen_string_literal: true

class MoneySerializer < Transmutation::Serializer
  attribute :subunit do
    object.fractional
  end

  attribute :currency do
    object.currency.iso_code
  end
end
