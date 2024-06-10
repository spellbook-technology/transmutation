# frozen_string_literal: true

class Product
  attr_accessor :id, :name, :description, :price_subunit, :price_currency

  def initialize(id:, name:, description:, price_subunit:, price_currency:)
    self.id = id
    self.name = name
    self.description = description
    self.price_subunit = price_subunit
    self.price_currency = price_currency
  end

  def price
    Money.new(price_subunit, price_currency)
  end

  # =====
  # Finder methods
  # =====

  def self.all
    [
      Product.new(id: 1, name: "Shoes", description: "A pair of shoes", price_subunit: 1000, price_currency: "GBP")
    ]
  end

  def self.find(id)
    all.find { |user| user.id == id }
  end

  # =====
  # JSON serialization
  # =====

  def to_json(options = {})
    as_json(options).to_json
  end

  def as_json(_options = {})
    {
      id: id,
      name: name,
      description: description,
      price_subunit: price_subunit,
      price_currency: price_currency
    }
  end
end
