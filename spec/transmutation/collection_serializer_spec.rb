# frozen_string_literal: true

RSpec.describe Transmutation::CollectionSerializer do
  before do
    open_struct_serializer_class = Class.new(Transmutation::Serializer) do
      attribute :first_name
    end

    stub_const("OpenStructSerializer", open_struct_serializer_class)
  end

  let(:example_object) do
    OpenStruct.new(first_name: "John", last_name: "Doe")
  end

  let(:example_array) do
    [example_object]
  end

  subject { Transmutation::CollectionSerializer.new(example_array) }

  describe "#as_json" do
    it "serializes the collection of objects" do
      json = subject.as_json

      expect(json).to be_an(Array)
      expect(json.length).to eq(1)

      serialized_object = json.first
      expect(serialized_object).to be_a(Hash)
      expect(serialized_object.keys).to contain_exactly("first_name")
      expect(serialized_object).to eq({ "first_name" => "John" })
    end
  end
end
