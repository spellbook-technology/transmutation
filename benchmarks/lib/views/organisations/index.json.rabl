# frozen_string_literal: true

collection @organisations
attributes :id, :name
node(:logo_url) { |organisation| "https://example.com/logos/companies/#{organisation.id}" }
