# frozen_string_literal: true

module Transmutation
  class OrganisationSerializer < Transmutation::Serializer
    attributes :id, :name

    attribute :logo_url do
      "https://example.com/logos/companies/#{object.id}"
    end
  end
end
