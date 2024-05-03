# frozen_string_literal: true

RSpec.describe Transmutation::Serializer do
  let(:example_serializer) do
    Class.new(Transmutation::Serializer) do
      attribute :first_name
    end
  end

  let(:example_object) do
    OpenStruct.new(first_name: "John", last_name: "Doe")
  end

  subject { example_serializer.new(example_object) }

  describe "#as_json" do
    it "returns a hash only with keys defined in the serializer" do
      expect(subject.as_json).to eq({ "first_name" => "John" })
    end
  end
end
