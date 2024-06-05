# frozen_string_literal: true

RSpec.describe Transmutation::CollectionSerializer do
  subject(:collection_serializer) { described_class.new(example_array) }

  before do
    example_object_serializer_class = Class.new(Transmutation::Serializer) do
      attribute :first_name
    end

    stub_const("ExampleObjectSerializer", example_object_serializer_class)

    example_object_class = Class.new do
      attr_accessor :first_name, :last_name

      def initialize(first_name:, last_name:)
        @first_name = first_name
        @last_name = last_name
      end
    end

    stub_const("ExampleObject", example_object_class)
  end

  let(:example_object) do
    ExampleObject.new(first_name: "John", last_name: "Doe")
  end

  let(:example_array) { [example_object] }

  describe "#as_json" do
    subject(:json) { collection_serializer.as_json }

    it "returns an array" do
      expect(json).to be_an(Array)
    end

    it "returns an array with serialized objects" do
      expect(json.first).to be_a(Hash)
    end

    it "returns an array with serialized objects with keys defined" do
      expect(json.first.keys).to contain_exactly("first_name")
    end

    it "returns a serialized array" do
      expect(json).to eq([{ "first_name" => "John" }])
    end
  end

  describe "#to_json" do
    subject(:json) { collection_serializer.to_json }

    it "returns a string" do
      expect(json).to be_a(String)
    end
  end
end
