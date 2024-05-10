# frozen_string_literal: true

RSpec.describe Transmutation::Utils do
  describe "#to_pascal_case" do
    context "when input is a string" do
      it "converts a snake_case string to PascalCase" do
        expect(described_class.to_pascal_case("test_string")).to eq("TestString")
      end

      it "converts a kebab-case string to PascalCase" do
        expect(described_class.to_pascal_case("test-string")).to eq("TestString")
      end

      it "returns the input string as is if it is already in PascalCase" do
        expect(described_class.to_pascal_case("TestString")).to eq("TestString")
      end

      it "returns an empty string if the input is an empty string" do
        expect(described_class.to_pascal_case("")).to eq("")
      end
    end

    context "when input is a symbol" do
      it "converts a word symbol to PascalCase" do
        expect(described_class.to_pascal_case(:test)).to eq("Test")
      end

      it "converts a snake_case string to PascalCase" do
        expect(described_class.to_pascal_case(:test_string)).to eq("TestString")
      end
    end
  end
end
