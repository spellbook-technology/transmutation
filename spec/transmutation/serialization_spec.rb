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

    context "when object has namespace" do
      before do
        test_example_object_class = Class.new do
          attr_accessor :first_name, :last_name

          def initialize(first_name:, last_name:)
            @first_name = first_name
            @last_name = last_name
          end
        end

        stub_const("Test::ExampleObject", test_example_object_class)

        test_example_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("Test::ExampleObjectSerializer", test_example_object_serializer_class)
      end

      let(:test_example_object) { Test::ExampleObject.new(first_name: "John", last_name: "Doe") }

      it "returns the serializer class for a given object with object's namespace" do
        serializer_class = controller.lookup_serializer!(test_example_object)
        expect(serializer_class).to eq(Test::ExampleObjectSerializer)
      end
    end

    context "when serializer is provided" do
      before do
        test_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("TestObjectSerializer", test_object_serializer_class)

        admin_test_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("Admin::TestObjectSerializer", admin_test_object_serializer_class)

        module Admin # rubocop:disable Lint/ConstantDefinitionInBlock,RSpec/LeakyConstantDeclaration
          class ExampleController # rubocop:disable RSpec/LeakyConstantDeclaration
            include Transmutation::Serialization
          end
        end
      end

      let(:admin_example_controller) { Admin::ExampleController.new }

      it "returns the serializer class for a given object with serializer (Class)" do
        serializer_class = controller.lookup_serializer!(example_object, serializer: TestObjectSerializer)
        expect(serializer_class).to eq(TestObjectSerializer)
      end

      it "returns the serializer class for a given object with serializer (String)" do
        serializer_class = controller.lookup_serializer!(example_object, serializer: "test_object")
        expect(serializer_class).to eq(TestObjectSerializer)
      end

      it "returns the serializer class for a given object with serializer (Symbol)" do
        serializer_class = controller.lookup_serializer!(example_object, serializer: :test_object)
        expect(serializer_class).to eq(TestObjectSerializer)
      end

      it "returns the serializer class for a given object with caller's namespace and serializer (Class)" do
        serializer_class = admin_example_controller.lookup_serializer!(example_object,
                                                                       serializer: TestObjectSerializer)
        expect(serializer_class).to eq(Admin::TestObjectSerializer)
      end

      it "returns the serializer class for a given object with caller's namespace and serializer (String)" do
        serializer_class = admin_example_controller.lookup_serializer!(example_object, serializer: "test_object")
        expect(serializer_class).to eq(Admin::TestObjectSerializer)
      end

      it "returns the serializer class for a given object with caller's namespace and serializer (Symbol)" do
        serializer_class = admin_example_controller.lookup_serializer!(example_object, serializer: :test_object)
        expect(serializer_class).to eq(Admin::TestObjectSerializer)
      end
    end

    context "when namespace is provided" do
      before do
        test_example_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("Test::ExampleObjectSerializer", test_example_object_serializer_class)

        user_test_example_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("User::Test::ExampleObjectSerializer", user_test_example_object_serializer_class)

        admin_user_test_example_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("Admin::User::Test::ExampleObjectSerializer", admin_user_test_example_object_serializer_class)

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

        module Admin # rubocop:disable Lint/ConstantDefinitionInBlock,RSpec/LeakyConstantDeclaration
          class ExampleController # rubocop:disable RSpec/LeakyConstantDeclaration
            include Transmutation::Serialization
          end
        end
      end

      let(:test_example_object) { Test::ExampleObject.new(first_name: "John", last_name: "Doe") }
      let(:admin_example_controller) { Admin::ExampleController.new }

      it "returns the serializer class for a given object with namespace (String)" do
        serializer_class = controller.lookup_serializer(example_object, namespace: "Test")
        expect(serializer_class).to eq(Test::ExampleObjectSerializer)
      end

      it "returns the serializer class for a given object with namespace (Symbol)" do
        serializer_class = controller.lookup_serializer(example_object, namespace: :test)
        expect(serializer_class).to eq(Test::ExampleObjectSerializer)
      end

      it "returns the serializer class for a given object with caller's namespace and namespace provided (String)" do
        serializer_class = admin_example_controller.lookup_serializer(test_example_object, namespace: "User")
        expect(serializer_class).to eq(Admin::User::Test::ExampleObjectSerializer)
      end

      it "returns the serializer class for a given object with caller's namespace and namespace provided (Symbol)" do
        serializer_class = admin_example_controller.lookup_serializer(test_example_object, namespace: :user)
        expect(serializer_class).to eq(Admin::User::Test::ExampleObjectSerializer)
      end

      it "returns the serializer class for a given object with caller's namespace but fully override namespace" do
        serializer_class = admin_example_controller.lookup_serializer(test_example_object, namespace: "::User")
        expect(serializer_class).to eq(User::Test::ExampleObjectSerializer)
      end
    end

    context "when namespace and serializer are provided" do
      before do
        test_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("TestObjectSerializer", test_object_serializer_class)

        user_test_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("User::TestObjectSerializer", user_test_object_serializer_class)

        admin_user_test_object_serializer_class = Class.new(Transmutation::Serializer) do
          attribute :first_name
        end

        stub_const("Admin::User::TestObjectSerializer", admin_user_test_object_serializer_class)

        module Admin # rubocop:disable Lint/ConstantDefinitionInBlock,RSpec/LeakyConstantDeclaration
          class ExampleController # rubocop:disable RSpec/LeakyConstantDeclaration
            include Transmutation::Serialization
          end
        end
      end

      let(:admin_example_controller) { Admin::ExampleController.new }

      it "returns the serializer class for a given object with namespace and serializer" do
        serializer_class = controller.lookup_serializer!(example_object, namespace: "User",
                                                                         serializer: TestObjectSerializer)
        expect(serializer_class).to eq(User::TestObjectSerializer)
      end

      it "returns the serializer class for a given object with caller's namespace, namespace and serializer" do
        serializer_class = admin_example_controller.lookup_serializer!(example_object, namespace: "User",
                                                                                       serializer: TestObjectSerializer)
        expect(serializer_class).to eq(Admin::User::TestObjectSerializer)
      end
    end

    context "when the serializer class is not found in the caller's namespace" do
      it "returns the serializer class for a given object from fallback strategy" do
        serializer_class = controller.lookup_serializer!(example_object, namespace: "Admin", serializer: "test_object")
        expect(serializer_class).to eq(ExampleObjectSerializer)
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
