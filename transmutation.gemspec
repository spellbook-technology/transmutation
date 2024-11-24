# frozen_string_literal: true

require_relative "lib/transmutation/version"

Gem::Specification.new do |spec|
  spec.name = "transmutation"
  spec.version = Transmutation::VERSION
  spec.authors = %w[nitemaeric borrabeer]
  spec.email = %w[daniel@spellbook.tech worapath.pakkavesa@spellbook.tech]

  spec.summary = "Ruby JSON serialization library"
  spec.homepage = "https://github.com/spellbook-technology/transmutation"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.5"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/spellbook-technology/transmutation"
  spec.metadata["changelog_uri"] = "https://github.com/spellbook-technology/transmutation/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/transmutation"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 7.2"
  spec.add_dependency "zeitwerk", "~> 2.6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
