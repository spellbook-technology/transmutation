# frozen_string_literal: true

json.array! organisations do |organisation|
  json.call(organisation, :id, :name)
  json.logo_url "https://example.com/logos/companies/#{organisation.id}"
end
