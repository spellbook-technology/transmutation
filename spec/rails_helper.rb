# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require_relative "dummy/config/environment"

abort("The Rails environment is not running in test mode!") if Rails.env.production?

require "rspec/rails"

# Load the database schema into the in-memory SQLite database
ActiveRecord::Schema.verbose = false
load Rails.root.join("db/schema.rb").to_s

RSpec.configure do |config|
  config.include Rails.application.routes.url_helpers, type: :request

  config.fixture_paths = [Rails.root.join("test/fixtures").to_s]
  config.use_transactional_fixtures = true
  config.global_fixtures = :all

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
