# frozen_string_literal: true

RSpec.describe Transmutation::Serializer do
  subject(:json) { example_serializer.new(example_object) }

  let(:example_serializer) do
    Class.new(Transmutation::Serializer) do
      attributes :first_name
    end
  end

  let(:example_object) do
    ExampleObject.new(first_name: "John", last_name: "Doe")
  end

  describe "#as_json" do
    it "returns a hash only with keys defined in the serializer" do
      expect(json.as_json).to eq({ "first_name" => "John" })
    end
  end

  describe "#to_json" do
    it "returns a string of hash with keys defined in the serializer" do
      expect(json.to_json).to eq("{\"first_name\":\"John\"}")
    end
  end
end
