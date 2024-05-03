# frozen_string_literal: true

RSpec.describe Transmutation::Serialization do # rubocop:disable Metrics/BlockLength
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
    OpenStruct.new(first_name: "John", last_name: "Doe")
  end

  subject { example_class.new }

  describe "#render" do
    it "calls super when :json is not provided" do
      expect(subject.render(html: example_object.to_h)).to eq({ html: { first_name: "John",
                                                                        last_name: "Doe" } })
    end

    it "calls super when :serialize is false" do
      json = subject.render(json: example_object.to_h, serialize: false)
      expect(json.keys).to contain_exactly(:first_name, :last_name)
      expect(json[:first_name]).to eq("John")
      expect(json[:last_name]).to eq("Doe")
    end

    it "calls super with Transmutation::CollectionSerializer when :json responds to :map" do
      example_array = [example_object]
      json = subject.render(json: example_array)

      expect(json).to be_an(Array)
      expect(json.length).to eq(1)

      serialized_object = json.first
      expect(serialized_object).to be_a(Hash)
      expect(serialized_object.keys).to contain_exactly("first_name")
      expect(serialized_object).to eq({ "first_name" => "John" })
    end

    it "calls super with the serializer for :json when :json does not respond to :map" do
      expect(subject.render(json: example_object)).to eq({ "first_name" => "John" })
    end
  end
end
