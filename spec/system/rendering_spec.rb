# frozen_string_literal: true

require_relative "dummy/app"

RSpec.describe "Rendering" do
  describe "Api::V1::UsersController" do
    subject(:controller) { Api::V1::UsersController.new }

    describe "#index" do
      let(:expected_json) do
        [
          { "id" => 1, "full_name" => "John Doe" },
          { "id" => 2, "full_name" => "Jane Doe" },
          { "id" => 3, "full_name" => "Adam Smith" },
          { "id" => 4, "full_name" => "Eve Smith" }
        ]
      end

      it "returns a list of users serialized with the Api::V1::UserSerializer" do
        expect(controller.index).to eq(expected_json)
      end
    end

    describe "#show" do
      let(:expected_json) do
        {
          "id" => 1,
          "first_name" => "John",
          "last_name" => "Doe",
          "full_name" => "John Doe"
        }
      end

      it "returns a user serialized with the Api::V1::Detailed::UserSerializer" do
        expect(controller.show(1)).to eq(expected_json)
      end
    end
  end

  describe "Api::V1::PostsController" do
    subject(:controller) { Api::V1::PostsController.new }

    describe "#index" do
      let(:expected_json) do
        [
          { "id" => 1, "title" => "First post" },
          { "id" => 2, "title" => "How does this work?" },
          { "id" => 3, "title" => "Second post!?" }
        ]
      end

      it "returns a list of posts serialized with the Api::V1::PostSerializer" do
        expect(controller.index).to eq(expected_json)
      end
    end

    describe "#show" do
      let(:expected_json) do
        {
          "id" => 1,
          "title" => "First post",
          "body" => "First!"
        }
      end

      it "returns a post serialized with the Api::V1::Detailed::PostSerializer" do
        expect(controller.show(1)).to eq(expected_json)
      end
    end
  end
end
