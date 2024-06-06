# frozen_string_literal: true

module Api
  class ApplicationController < BaseController
    include Transmutation::Serialization
  end
end
