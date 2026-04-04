# frozen_string_literal: true

module Api
  module V1
    class HealthController < Api::ApplicationController
      def index
        render json: { ok: true }
      end

      def download
        send_data "binary data content", filename: "report.txt", type: "text/plain"
      end
    end
  end
end
