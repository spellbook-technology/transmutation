# frozen_string_literal: true

module Api
  module V1
    class HealthController < Api::ApplicationController
      def index
        render(json: { ok: true })
      end
    end
  end
end
