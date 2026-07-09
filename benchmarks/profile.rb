# frozen_string_literal: true

require "bundler/setup"
Bundler.require
require "memory_profiler"

Oj.optimize_rails
MultiJson.use(:oj)

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path("lib", __dir__))
loader.collapse(File.expand_path("lib/models", __dir__))
loader.collapse(File.expand_path("lib/serializers", __dir__))
loader.setup

organisation = Organisation.new(id: 1, name: "Example Inc.")
user = User.new(id: 1, first_name: "John", last_name: "Doe", organisation_id: 1)
organisations = [organisation] + 29.times.map { Organisation.new(id: _1 + 2, name: "Org #{_1 + 2}") }

def profile(label, &block)
  # warm caches / autoloads before measuring
  block.call
  report = MemoryProfiler.report(&block)
  puts "\n=== #{label} : #{report.total_allocated} objects / #{report.total_allocated_memsize} bytes allocated ==="
  puts "-- allocated objects by class --"
  report.allocated_objects_by_class.first(8).each { |r| puts format("  %6d  %s", r[:count], r[:data]) }
  puts "-- allocated objects by location (top) --"
  report.allocated_objects_by_location.first(8).each { |r| puts format("  %6d  %s", r[:count], r[:data]) }
end

profile("Attributes  (1 org)")        { Transmutation::OrganisationSerializer.new(organisation).to_json }
profile("Has Many    (1 user)")       { Transmutation::UserSerializer.new(user).to_json }
profile("Collection  (30 orgs)")      { organisations.map { Transmutation::OrganisationSerializer.new(_1) }.to_json }
