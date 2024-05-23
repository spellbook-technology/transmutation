# frozen_string_literal: true

RSpec.describe Transmutation::StringRefinements do
  using described_class

  describe "#camelcase" do
    it "answers empty string as empty string" do
      expect("".camelcase).to eq("")
    end

    it "answers camelcase as camelcase" do
      expect("ThisIsATest".camelcase).to eq("ThisIsATest")
    end

    it "answers capitalized as capitalized" do
      expect("Test".camelcase).to eq("Test")
    end

    it "answers upcase as upcase" do
      expect("TEST".camelcase).to eq("TEST")
    end

    it "answers downcase as capitalized" do
      expect("test".camelcase).to eq("Test")
    end

    it "answers consecutive spaces as as empty string" do
      expect("   ".camelcase).to eq("")
    end

    it "answers consecutive underscores as empty string" do
      expect("___".camelcase).to eq("")
    end

    it "answers consecutive dashes as empty string" do
      expect("---".camelcase).to eq("")
    end

    it "answers consecutive slashes as empty string" do
      expect("///".camelcase).to eq("")
    end

    it "answers consecutive, odd colons as empty string" do
      expect(":::".camelcase).to eq("")
    end

    it "answers consecutive, even colons as empty string" do
      expect("::::".camelcase).to eq("")
    end

    it "answers space delimit as capitalized words delimited by nothing" do
      expect("this is a test".camelcase).to eq("ThisIsATest")
    end

    it "answers underscore delimit as capitalized words delimited by nothing" do
      expect("this_is_a_test".camelcase).to eq("ThisIsATest")
    end

    it "answers dash delimit as capitalized words delimited by double colons" do
      expect("this-is-a-test".camelcase).to eq("This::Is::A::Test")
    end

    it "answers slash delimit as capitalized words delimited by double colons" do
      expect("this/is/a/test".camelcase).to eq("This::Is::A::Test")
    end

    it "answers single colon delimit as capitalized words delimited by double colons" do
      expect("this:is:a:test".camelcase).to eq("This::Is::A::Test")
    end

    it "answers double colon delimit as capitalized words delimited by double colons" do
      expect("this::is::a::test".camelcase).to eq("This::Is::A::Test")
    end

    it "answers multi-space delimit as capitalized words delimited by nothing" do
      expect("example   test".camelcase).to eq("ExampleTest")
    end

    it "answers spaced, underscore delimit as capitalized words delimited by nothing" do
      expect("example _ test".camelcase).to eq("ExampleTest")
    end

    it "answers spaced, dash delimit as capitalized words delimited by double colon" do
      expect("example - test".camelcase).to eq("Example::Test")
    end

    it "answers spaced, slash delimit as capitalized words delimited by double colon" do
      expect("example / test".camelcase).to eq("Example::Test")
    end

    it "answers spaced, single colon delimit as capitalized words delimited by double colon" do
      expect("example : test".camelcase).to eq("Example::Test")
    end

    it "answers spaced, double colon delimit as capitalized words delimited by double colon" do
      expect("example :: test".camelcase).to eq("Example::Test")
    end

    it "transforms mixed space, underscore, dash, slash, colon, and double colon delimiters" do
      expect("this is_a-mixed/test:case::example".camelcase).to eq(
        "ThisIsA::Mixed::Test::Case::Example"
      )
    end
  end

  describe "#first" do
    subject(:string) { "seedlings" }

    it "answers first letter" do
      expect(string.first).to eq("s")
    end

    it "answers first letters with positive number" do
      expect(string.first(3)).to eq("see")
    end

    it "answers empty string with negative number" do
      expect(string.first(-1)).to eq("")
    end

    it "answers itself when empty" do
      expect("".first).to eq("")
    end
  end

  describe "#capitalize" do
    it "answers empty string as empty string" do
      expect("".capitalize).to eq("")
    end

    it "upcases first letter only" do
      expect("test".capitalize).to eq("Test")
    end
  end
end
