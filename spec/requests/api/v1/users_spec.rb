# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  describe "GET /api/v1/users" do
    it "returns a list of users serialized with Api::V1::UserSerializer", :aggregate_failures do
      get api_v1_users_path

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/json")
      expect(JSON.parse(response.body)).to eq([
                                                { "id" => 1, "full_name" => "John Doe" },
                                                { "id" => 2, "full_name" => "Jane Doe" },
                                                { "id" => 3, "full_name" => "Adam Smith" },
                                                { "id" => 4, "full_name" => "Eve Smith" }
                                              ])
    end
  end

  describe "GET /api/v1/users/:id" do
    let(:expected_json) do
      {
        "id" => 1,
        "first_name" => "John",
        "last_name" => "Doe",
        "full_name" => "John Doe",
        "posts" => [
          { "id" => 1, "title" => "First post" },
          { "id" => 3, "title" => "Second post!?" }
        ],
        "comments" => [
          { "id" => 1, "body" => "First!" },
          { "id" => 3, "body" => "Third!" }
        ],
        "published_posts" => [
          { "id" => 1, "title" => "First post" }
        ]
      }
    end

    it "returns a user serialized with Api::V1::Detailed::UserSerializer", :aggregate_failures do
      get api_v1_user_path(1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(expected_json)
    end
  end
end
