# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

require "transmutation"

module Dummy
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)

    config.load_defaults Rails::VERSION::STRING.to_f

    config.autoload_paths << config.root.join("app/serializers")

    config.api_only = true
    config.eager_load = false
  end
end
