# frozen_string_literal: true

module Api
  class ApplicationController < ::ApplicationController
    include Transmutation::Serialization
  end
end
