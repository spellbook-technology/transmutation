# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Posts", type: :request do
  describe "GET /api/v1/posts" do
    it "returns a list of posts serialized with Api::V1::PostSerializer", :aggregate_failures do
      get api_v1_posts_path

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([
                                                { "id" => 1, "title" => "First post" },
                                                { "id" => 2, "title" => "How does this work?" },
                                                { "id" => 3, "title" => "Second post!?" }
                                              ])
    end
  end

  describe "GET /api/v1/posts/:id" do
    it "returns a post serialized with Api::V1::Detailed::PostSerializer", :aggregate_failures do
      get api_v1_post_path(1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "id" => 1,
        "title" => "First post",
        "body" => "First!",
        "user" => {
          "id" => 1,
          "first_name" => "John",
          "last_name" => "Doe",
          "full_name" => "John Doe"
        }
      )
    end
  end
end
