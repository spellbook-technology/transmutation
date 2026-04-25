# frozen_string_literal: true

json.call(organisation, :id, :name)
json.logo_url "https://example.com/logos/companies/#{organisation.id}"
