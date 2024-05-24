# frozen_string_literal: true

RSpec.describe Transmutation::Serialization do
  subject(:controller) { example_class.new }

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
      expect(controller.render(html: example_object)).to eq({ html: example_object })
    end

    it "calls super when :serialize is false" do
      expect(controller.render(json: example_object, serialize: false)).to eq(example_object)
    end

    it "calls super with the serializer for :json when :json does not respond to :map" do
      expect(controller.render(json: example_object)).to eq({ "first_name" => "John" })
    end
  end

  describe "#lookup_serializer!" do
    it "returns the serializer class for a given object" do
      serializer_class = controller.lookup_serializer!(example_object)
      expect(serializer_class).to eq(ExampleObjectSerializer)
    end

    context "when namespace is empty and variant is nil" do
      it "returns the serializer class for a given object" do
        serializer_class = controller.lookup_serializer(example_object)
        expect(serializer_class).to eq(ExampleObjectSerializer)
      end
    end

    context "when namespace is not empty" do
      before do
        test_example_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("Test::ExampleObjectSerializer", test_example_object_serializer_class)

        user_test_example_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("User::Test::ExampleObjectSerializer", user_test_example_object_serializer_class)

        user_example_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("User::ExampleObjectSerializer", user_example_object_serializer_class)

        test_example_object_class = Class.new do
          attr_accessor :first_name, :last_name

          def initialize(first_name:, last_name:)
            @first_name = first_name
            @last_name = last_name
          end
        end

        stub_const("Test::ExampleObject", test_example_object_class)
      end

      let(:test_example_object) { Test::ExampleObject.new(first_name: "John", last_name: "Doe") }

      it "returns the serializer class for a given object with namespace" do
        serializer_class = controller.lookup_serializer(example_object, namespace: "Test")
        expect(serializer_class).to eq(Test::ExampleObjectSerializer)
      end

      it "returns the serializer class for a given object with namespace and parent module" do
        serializer_class = controller.lookup_serializer(test_example_object, namespace: "User")
        expect(serializer_class).to eq(User::Test::ExampleObjectSerializer)
      end

      it "returns the serializer class for a given object with fully override namespace" do
        serializer_class = controller.lookup_serializer(test_example_object, namespace: "::User")
        expect(serializer_class).to eq(User::Test::ExampleObjectSerializer)
      end
    end

    context "when variant is not nil" do
      before do
        test_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("TestObjectSerializer", test_object_serializer_class)
      end

      it "returns the serializer class for a given object with variant" do
        serializer_class = controller.lookup_serializer(example_object, variant: :test_object)
        expect(serializer_class).to eq(TestObjectSerializer)
      end
    end

    context "when namespace is not empty and variant is not nil" do
      before do
        user_test_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("User::TestObjectSerializer", user_test_object_serializer_class)
      end

      it "returns the serializer class for a given object with namespace and variant supported" do
        serializer_class = controller.lookup_serializer(example_object, namespace: "User", variant: :test_object)
        expect(serializer_class).to eq(User::TestObjectSerializer)
      end
    end

    it "raises an error when the serializer class is not found" do
      object = Struct.new(:first_name, :last_name).new("John", "Doe")
      expect { controller.lookup_serializer!(object) }.to raise_error(NameError)
    end
  end

  describe "#lookup_serializer" do
    it "returns the serializer class for a given object" do
      serializer_class = controller.lookup_serializer(example_object)
      expect(serializer_class).to eq(ExampleObjectSerializer)
    end

    it "returns nil when the serializer class is not found" do
      object = Struct.new(:first_name, :last_name).new("John", "Doe")
      expect(controller.lookup_serializer(object)).to eq(nil)
    end
  end

  describe "#serialize" do
    before do
      test_example_object_serializer_class = Class.new(Transmutation::Serializer) do
        attribute :first_name
      end

      stub_const("Test::ExampleObjectSerializer", test_example_object_serializer_class)
    end

    it "returns the wrapped object in corresponding serializer" do
      expect(controller.serialize(example_object).class).to eq(ExampleObjectSerializer)
    end

    it "returns the wrapped object in corresponding serializer with namespace" do
      expect(controller.serialize(example_object, namespace: "Test").class).to eq(Test::ExampleObjectSerializer)
    end
  end
end
