# frozen_string_literal: true

class Product < ActiveRecord::Base
  def price
    Money.new(price_subunit, price_currency)
  end
end
