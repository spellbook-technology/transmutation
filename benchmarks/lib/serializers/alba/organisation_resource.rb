# frozen_string_literal: true

module Alba
  class OrganisationResource
    include Alba::Resource

    attributes :id, :name

    attribute :logo_url do |resource|
      "https://example.com/logos/companies/#{resource.id}"
    end
  end
end
