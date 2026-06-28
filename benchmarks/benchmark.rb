# frozen_string_literal: true

require "bundler/setup"
require "active_support/core_ext/object/deep_dup" # Required for Active Model Serializers

Bundler.require

Oj.optimize_rails # Use OJ for benchmarks using #to_json
MultiJson.use(:oj) # Use OJ by default from multi_json

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path("lib", __dir__))
loader.collapse(File.expand_path("lib/models", __dir__))
loader.collapse(File.expand_path("lib/serializers", __dir__))
loader.setup

Rabl.configure do |config|
  config.include_json_root = false
  config.include_child_root = false
end

user_jbuilder_template = File.read(File.expand_path("lib/views/users/show.json.jbuilder", __dir__))
post_jbuilder_template = File.read(File.expand_path("lib/views/posts/show.json.jbuilder", __dir__))
organisation_jbuilder_template = File.read(File.expand_path("lib/views/organisations/show.json.jbuilder", __dir__))
organisations_jbuilder_template = File.read(File.expand_path("lib/views/organisations/index.json.jbuilder", __dir__))

user_rabl_template = File.read(File.expand_path("lib/views/users/show.json.rabl", __dir__))
post_rabl_template = File.read(File.expand_path("lib/views/posts/show.json.rabl", __dir__))
organisation_rabl_template = File.read(File.expand_path("lib/views/organisations/show.json.rabl", __dir__))
organisations_rabl_template = File.read(File.expand_path("lib/views/organisations/index.json.rabl", __dir__))

organisation = Organisation.new(id: 1, name: "Example Inc.")
user = User.new(id: 1, first_name: "John", last_name: "Doe", organisation_id: 1)
post = Post.new(id: 1, title: "Sample Post", body: "Sample Body", user_id: 1)

organisations = [organisation] + 29.times.map { Organisation.new(id: _1 + 2, name: "Example Inc. #{_1 + 2}") }

# Optionally load another revision of transmutation (e.g. main) into an isolated namespace so it can
# be benchmarked side by side with the working tree (head) in a single process. This relies on Ruby's
# experimental Namespace feature (Ruby 4.0+, RUBY_NAMESPACE=1); if it is unavailable or fails to load,
# we simply skip the comparison and benchmark head on its own.
# The gem's source files in load order. transmutation.rb itself is skipped: it boots Zeitwerk, which
# would bind the top-level ::Transmutation constant and defeat the isolation, so we recreate its
# module-level setup inline instead.
TRANSMUTATION_MAIN_SOURCES = %w[
  transmutation/class_attributes
  transmutation/serialization/lookup/serializer_not_found
  transmutation/serialization/lookup
  transmutation/serialization/rendering
  transmutation/serialization
  transmutation/serializer
  transmutation/object_serializer
].freeze

def load_transmutation_main
  lib = ENV.fetch("TRANSMUTATION_MAIN_LIB", nil)
  return unless lib

  # Evaluate the library's source as strings into an anonymous module. A string `module_eval` nests
  # under the receiver, so every `module Transmutation` lands in `wrapper::Transmutation` — a copy
  # fully isolated from the working tree's top-level `Transmutation`, with no source rewriting.
  wrapper = Module.new
  TRANSMUTATION_MAIN_SOURCES.each do |source|
    wrapper.module_eval(File.read(File.join(lib, "#{source}.rb")), "#{source}.rb")

    next unless source.end_with?("class_attributes")

    wrapper.module_eval(<<~RUBY, "transmutation_main_bootstrap.rb")
      module Transmutation
        extend ClassAttributes
        class_attribute :max_depth, default: 1
        class Error < StandardError; end
      end
    RUBY
  end

  # Load the benchmark's own serializers into the same isolated copy.
  Dir[File.expand_path("lib/serializers/transmutation/*.rb", __dir__)].sort.each do |file|
    wrapper.module_eval(File.read(file), file)
  end

  # Naming the module (a top-level constant) lets the serializer's namespace-based association lookup
  # resolve its sibling serializers, exactly as it does for the working-tree copy.
  Object.const_set(:TransmutationMain, wrapper::Transmutation)
rescue StandardError, ScriptError => e
  warn "Skipping `transmutation (main)` comparison: #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
  nil
end

TRANSMUTATION_MAIN = load_transmutation_main
warn(TRANSMUTATION_MAIN ? "Benchmarking head vs main." : "Benchmarking head only.")

GemBenchmarks.report output: false do
  group("Attributes") do
    example("transmutation (HEAD)")     { Transmutation::OrganisationSerializer.new(organisation).to_json }
    example("transmutation (main)")     { TRANSMUTATION_MAIN::OrganisationSerializer.new(organisation).to_json } if TRANSMUTATION_MAIN
    example("panko_serializer")         { PankoSerializer::OrganisationSerializer.new.serialize_to_json(organisation) }
    example("jbuilder")                 { Jbuilder.encode { |json| json.instance_eval(organisation_jbuilder_template); json.target! } }
    example("representable")            { Representable::OrganisationRepresenter.new(organisation).to_json }
    example("active_model_serializers") { ActiveModelSerializers::OrganisationSerializer.new(organisation, namespace: ActiveModelSerializers).to_json }
    example("rabl")                     { Rabl::Renderer.json(organisation, organisation_rabl_template) }
    example("alba")                     { Alba::OrganisationResource.new(organisation).to_json }
  end

  group("Has One / Belongs To") do
    example("transmutation (HEAD)")     { Transmutation::PostSerializer.new(post).to_json }
    example("transmutation (main)")     { TRANSMUTATION_MAIN::PostSerializer.new(post).to_json } if TRANSMUTATION_MAIN
    example("panko_serializer")         { PankoSerializer::PostSerializer.new(except: { user: [:posts] }).serialize_to_json(post) }
    example("jbuilder")                 { Jbuilder.encode { |json| json.instance_eval(post_jbuilder_template); json.target! } }
    example("representable")            { Representable::PostRepresenter.new(post).to_json }
    example("active_model_serializers") { ActiveModelSerializers::PostSerializer.new(post, namespace: ActiveModelSerializers).to_json }
    example("rabl")                     { Rabl::Renderer.json(post, post_rabl_template) }
    example("alba")                     { Alba::PostResource.new(post, within: :user).to_json }
  end

  group("Has Many") do
    example("transmutation (HEAD)")     { Transmutation::UserSerializer.new(user).to_json }
    example("transmutation (main)")     { TRANSMUTATION_MAIN::UserSerializer.new(user).to_json } if TRANSMUTATION_MAIN
    example("panko_serializer")         { PankoSerializer::UserSerializer.new.serialize_to_json(user) }
    example("jbuilder")                 { Jbuilder.encode { |json| json.instance_eval(user_jbuilder_template); json.target! } }
    example("representable")            { Representable::UserRepresenter.new(user).to_json }
    example("active_model_serializers") { ActiveModelSerializers::UserSerializer.new(user, namespace: ActiveModelSerializers).to_json }
    example("rabl")                     { Rabl::Renderer.json(user, user_rabl_template) }
    example("alba")                     { Alba::UserResource.new(user, within: :posts).to_json }
  end

  group("Collection") do
    example("transmutation (HEAD)")     { organisations.map { Transmutation::OrganisationSerializer.new(_1) }.to_json }
    example("transmutation (main)")     { organisations.map { TRANSMUTATION_MAIN::OrganisationSerializer.new(_1) }.to_json } if TRANSMUTATION_MAIN
    example("panko_serializer")         { Panko::ArraySerializer.new(organisations, each_serializer: PankoSerializer::OrganisationSerializer).to_json }
    example("jbuilder")                 { Jbuilder.encode { |json| json.instance_eval(organisations_jbuilder_template); json.target! } }
    example("representable")            { Representable::OrganisationRepresenter.for_collection.new(organisations).to_json }
    example("active_model_serializers") { ActiveModel::Serializer::CollectionSerializer.new(organisations, each_serializer: ActiveModelSerializers::OrganisationSerializer, namespace: ActiveModelSerializers).to_json }
    example("rabl")                     { Rabl::Renderer.json(organisations, organisations_rabl_template) }
    example("alba")                     { Alba::OrganisationResource.new(organisations, within: :posts).to_json }
  end
end
