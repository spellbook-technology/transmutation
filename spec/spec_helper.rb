# frozen_string_literal: true

require "pry"
require "simplecov"
require "simplecov-lcov"
require "undercover"

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter,
                                                                SimpleCov::Formatter::LcovFormatter])
SimpleCov.start do
  add_filter(%r{^/spec/})
end

require "transmutation"
require "support/markdown_helper"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
