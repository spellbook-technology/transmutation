# frozen_string_literal: true

require "bundler/setup"
Bundler.require

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

def stream(serializer)
  writer = Oj::StringWriter.new(mode: :rails)
  serializer.write_json(writer)
  writer.to_s
end

def stream_collection(objects, serializer_class)
  writer = Oj::StringWriter.new(mode: :rails)
  writer.push_array
  objects.each { |object| serializer_class.new(object).write_json(writer) }
  writer.pop
  writer.to_s
end

Benchmark.ips do |x|
  x.report("attributes: hash")      { Transmutation::OrganisationSerializer.new(organisation).to_json }
  x.report("attributes: stream")    { stream(Transmutation::OrganisationSerializer.new(organisation)) }
  x.report("has_many: hash")        { Transmutation::UserSerializer.new(user).to_json }
  x.report("has_many: stream")      { stream(Transmutation::UserSerializer.new(user)) }
  x.report("collection: hash")      { organisations.map { Transmutation::OrganisationSerializer.new(_1) }.to_json }
  x.report("collection: stream")    { stream_collection(organisations, Transmutation::OrganisationSerializer) }
  x.report("collection: panko")     { Panko::ArraySerializer.new(organisations, each_serializer: PankoSerializer::OrganisationSerializer).to_json }
  x.compare!
end
