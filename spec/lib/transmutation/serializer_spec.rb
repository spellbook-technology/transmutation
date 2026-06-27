# frozen_string_literal: true

RSpec.describe Transmutation::Serializer do
  subject(:json) { example_serializer.new(example_object) }

  before do
    example_object_class = Class.new do
      attr_accessor :first_name, :last_name

      def initialize(first_name:, last_name:)
        @first_name = first_name
        @last_name = last_name
      end
    end

    stub_const("ExampleObject", example_object_class)
  end

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

  describe "conditional rendering" do
    context "with a Symbol condition" do
      let(:example_serializer) do
        Class.new(Transmutation::Serializer) do
          attribute :first_name
          attribute :last_name, if: :admin?

          def admin?
            object.first_name == "John"
          end
        end
      end

      it "includes the attribute when the condition is truthy" do
        expect(json.as_json).to eq({ "first_name" => "John", "last_name" => "Doe" })
      end

      it "excludes the attribute when the condition is falsy" do
        object = ExampleObject.new(first_name: "Jane", last_name: "Doe")

        expect(example_serializer.new(object).as_json).to eq({ "first_name" => "Jane" })
      end
    end

    context "with a Proc condition" do
      let(:example_serializer) do
        Class.new(Transmutation::Serializer) do
          attribute :first_name
          attribute :last_name, if: -> { object.last_name == "Doe" }
        end
      end

      it "evaluates the proc in the serializer's context" do
        expect(json.as_json).to eq({ "first_name" => "John", "last_name" => "Doe" })
      end

      it "excludes the attribute when the proc is falsy" do
        object = ExampleObject.new(first_name: "John", last_name: "Smith")

        expect(example_serializer.new(object).as_json).to eq({ "first_name" => "John" })
      end
    end

    context "with an unless condition" do
      let(:example_serializer) do
        Class.new(Transmutation::Serializer) do
          attribute :first_name
          attribute :last_name, unless: :hidden?

          def hidden?
            object.first_name == "John"
          end
        end
      end

      it "excludes the attribute when the condition is truthy" do
        expect(json.as_json).to eq({ "first_name" => "John" })
      end

      it "includes the attribute when the condition is falsy" do
        object = ExampleObject.new(first_name: "Jane", last_name: "Doe")

        expect(example_serializer.new(object).as_json).to eq({ "first_name" => "Jane", "last_name" => "Doe" })
      end
    end

    context "with both if and unless conditions" do
      let(:example_serializer) do
        Class.new(Transmutation::Serializer) do
          attribute :first_name
          attribute :last_name, if: -> { object.first_name == "John" }, unless: -> { object.last_name == "Smith" }
        end
      end

      it "includes the attribute only when if is truthy and unless is falsy" do
        expect(json.as_json).to eq({ "first_name" => "John", "last_name" => "Doe" })
      end

      it "excludes the attribute when unless is truthy" do
        object = ExampleObject.new(first_name: "John", last_name: "Smith")

        expect(example_serializer.new(object).as_json).to eq({ "first_name" => "John" })
      end
    end

    context "when applied via the attributes shorthand" do
      let(:example_serializer) do
        Class.new(Transmutation::Serializer) do
          attributes :first_name, :last_name, if: :admin?

          def admin?
            false
          end
        end
      end

      it "applies the condition to every attribute" do
        expect(json.as_json).to eq({})
      end
    end
  end
end
