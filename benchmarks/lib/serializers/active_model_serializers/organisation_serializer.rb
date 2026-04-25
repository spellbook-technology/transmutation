# frozen_string_literal: true

module ActiveModelSerializers
  class OrganisationSerializer < ActiveModel::Serializer
    attributes :id, :name

    attribute :logo_url do
      "https://example.com/logos/companies/#{object.id}"
    end
  end
end
