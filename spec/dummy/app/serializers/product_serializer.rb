# frozen_string_literal: true

class ProductSerializer < Transmutation::Serializer
  attributes :id, :name

  has_one :price
end
