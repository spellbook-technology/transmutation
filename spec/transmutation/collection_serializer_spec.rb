# frozen_string_literal: true

RSpec.describe Transmutation::CollectionSerializer do
  subject(:array) { described_class.new(example_array) }

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

  let(:example_array) do
    [example_object]
  end

  describe "#as_json" do
    subject(:json) { array.as_json }

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
      expect(json.first).to eq({ "first_name" => "John" })
    end

    describe "calls the appropriate serializer for each object" do
      let(:serializer) { instance_double(ExampleObjectSerializer) }

      before do
        allow(Transmutation::Serialization).to receive(:lookup_serializer).with(example_object).and_return(serializer)
        allow(serializer).to receive(:new).with(example_object).and_return(serializer)
        allow(serializer).to receive(:as_json).with({}).and_return({ "first_name" => "John" })
        array.as_json
      end

      it "calls lookup_serializer on each object" do
        expect(Transmutation::Serialization).to have_received(:lookup_serializer).with(example_object)
      end

      it "initialize appropriate serializer on each object" do
        expect(serializer).to have_received(:new).with(example_object)
      end

      it "calls as_json from the appropriate serializer on each object" do
        expect(serializer).to have_received(:as_json).with({})
      end
    end
  end
end
