# frozen_string_literal: true

module Representable
  class OrganisationRepresenter < Representable::Decorator
    include Representable::JSON

    property :id
    property :name
    property :logo_url, getter: ->(represented:, **) { "https://example.com/logos/companies/#{represented.id}" }
  end
end
