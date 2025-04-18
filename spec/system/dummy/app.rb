# frozen_string_literal: true

require "json"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.collapse("#{__dir__}/*")
loader.ignore(__FILE__)
loader.setup
