# frozen_string_literal: true

class ExampleObject
  attr_accessor :first_name, :last_name

  def initialize(first_name:, last_name:)
    @first_name = first_name
    @last_name = last_name
  end

  def to_h
    { first_name: first_name, last_name: last_name }
  end
end
