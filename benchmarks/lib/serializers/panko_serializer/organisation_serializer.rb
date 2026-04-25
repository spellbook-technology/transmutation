# frozen_string_literal: true

module PankoSerializer
  class OrganisationSerializer < Panko::Serializer
    attributes :id, :name, :logo_url

    def logo_url
      "https://example.com/logos/companies/#{object.id}"
    end
  end
end
