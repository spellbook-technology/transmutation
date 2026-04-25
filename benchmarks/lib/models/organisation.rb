# frozen_string_literal: true

class Organisation < Base
  attr_accessor :id, :name

  def self.all
    @all ||= [
      Organisation.new(id: 1, name: "Organisation 1"),
    ]
  end
end
