# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Health", type: :request do
  describe "GET /api/v1/health" do
    it "returns a JSON object without serialization", :aggregate_failures do
      get api_v1_health_index_path

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ "ok" => true })
    end
  end

  describe "GET /api/v1/health/download" do
    it "returns binary data using send_data", :aggregate_failures do
      get download_api_v1_health_index_path

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/plain")
      expect(response.body).to eq("binary data content")
    end

    it "sets the correct Content-Disposition header" do
      get download_api_v1_health_index_path

      expect(response.headers["Content-Disposition"]).to include("report.txt")
    end
  end
end
