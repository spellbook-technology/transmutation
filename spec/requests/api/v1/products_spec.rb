# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Products", type: :request do
  describe "GET /api/v1/products/:id" do
    it "returns a product serialized with ProductSerializer", :aggregate_failures do
      get api_v1_product_path(1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "id" => 1,
        "name" => "Shoes",
        "price" => {
          "subunit" => 1000,
          "currency" => "GBP"
        }
      )
    end
  end
end
