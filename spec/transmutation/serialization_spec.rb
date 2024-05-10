# frozen_string_literal: true

RSpec.describe Transmutation::Serialization do
  subject(:controller) { example_class.new }

  before do
    example_object_serializer_class = Class.new(Transmutation::Serializer) do
      attribute :first_name
    end

    stub_const("ExampleObjectSerializer", example_object_serializer_class)
  end

  let(:dummy_class) do
    Class.new do
      def render(**args)
        return args unless args[:json]
        return args[:json].as_json if args[:json].respond_to?(:as_json)

        args[:json]
      end
    end
  end

  let(:example_class) do
    Class.new(dummy_class) do
      include Transmutation::Serialization
    end
  end

  let(:example_object) do
    ExampleObject.new(first_name: "John", last_name: "Doe")
  end

  describe "#render" do
    it "calls super when :json is not provided" do
      expect(controller.render(html: example_object.to_h)).to eq({ html: { first_name: "John",
                                                                           last_name: "Doe" } })
    end

    it "calls super without serializer when :serialize is false" do
      json = controller.render(json: example_object.to_h, serialize: false)
      expect(json.keys).to contain_exactly(:first_name, :last_name)
    end

    describe "calls super with Transmutation::CollectionSerializer when :json responds to :map" do
      subject(:json) { controller.render(json: example_array) }

      let(:example_array) { [example_object] }

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
    end

    it "calls super with the serializer for :json when :json does not respond to :map" do
      expect(controller.render(json: example_object)).to eq({ "first_name" => "John" })
    end
  end

  describe "#lookup_serializer" do
    it "returns the serializer class for a given object" do
      serializer_class = described_class.lookup_serializer(example_object)
      expect(serializer_class).to eq(ExampleObjectSerializer)
    end

    it "raises an error if the serializer class is not found" do
      object = Struct.new(:first_name, :last_name).new("John", "Doe")
      expect { described_class.lookup_serializer(object) }.to raise_error(NameError)
    end
  end

  describe "#serialize" do
    it "returns the serialized object as JSON" do
      json = described_class.serialize(example_object)
      expect(json).to eq({ "first_name" => "John" })
    end
  end
end
