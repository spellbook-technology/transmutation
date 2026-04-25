# frozen_string_literal: true

module Representable
  class PostRepresenter < Representable::Decorator
    include Representable::JSON

    property :id
    property :title
    property :body

    property :user do
      property :id
      property :first_name
      property :full_name, getter: ->(represented:, **) { "#{represented.first_name} #{represented.last_name}" }
    end
  end
end
