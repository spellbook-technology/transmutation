# frozen_string_literal: true

RSpec.describe Transmutation::Serialization do
  extend MarkdownHelper

  serializer_lookup_table = parse_markdown_table(<<~TABLE, nil_value: "")
    | context                     | namespace            | serializer                      | expected_namespace                  | expected_serializer                                       |
    | --------------------------- | -------------------- | ------------------------------- | ----------------------------------- | --------------------------------------------------------- |
    | default                     |                      |                                 | Api::V1::Admin                      | Api::V1::Admin::Chat::UserSerializer                      |
    | namespace                   | Detailed             |                                 | Api::V1::Admin::Detailed            | Api::V1::Admin::Detailed::Chat::UserSerializer            |
    | repeated namespace          | Admin                |                                 | Api::V1::Admin::Admin               | Api::V1::Admin::Admin::Chat::UserSerializer               |
    | nested namespace            | External::ProviderA  |                                 | Api::V1::Admin::External::ProviderA | Api::V1::Admin::External::ProviderA::Chat::UserSerializer |
    | top-level namespace         | ::Public             |                                 | Public                              | ::Public::Chat::UserSerializer                            |
    | nested serializer           |                      | External::ProviderA::Chat::User | Api::V1::Admin                      | Api::V1::Admin::External::ProviderA::Chat::UserSerializer |
    | serializer                  |                      | Chat::DetailedUser              | Api::V1::Admin                      | Api::V1::Admin::Chat::DetailedUserSerializer              |
    | top-level serializer        | Admin                | ::Chat::DetailedUser            | Api::V1::Admin::Admin               | ::Chat::DetailedUserSerializer                            |
    | namespace and serializer    | Admin                | Chat::DetailedUser              | Api::V1::Admin::Admin               | Api::V1::Admin::Admin::Chat::DetailedUserSerializer       |
    | explicitly named serializer |                      | Chat::UserSerializer            | Api::V1::Admin                      | Api::V1::Admin::Chat::UserSerializer                      |
  TABLE

  caller_class_name = "Api::V1::Admin::UsersController"
  object_class_name = "Chat::User"

  let(:caller_class) do
    Class.new do
      include Transmutation::Serialization
    end
  end
  let(:caller) { Object.const_get(caller_class_name).new }
  let(:object) { Object.const_get(object_class_name).new }

  let(:object_class) do
    Class.new do
      def first_name = "John"
      def last_name = "Doe"
    end
  end

  before do
    stub_const(caller_class_name, caller_class)
    stub_const(object_class_name, object_class)
  end

  # TODO: Add tests to show that the lookup will bubble up the namespace heirarchy
  describe "#lookup_serializer" do
    serializer_lookup_table.each do |row|
      context "when given #{row[:context]}" do
        subject(:lookup_serializer) do
          caller.lookup_serializer(object, namespace: row[:namespace], serializer: row[:serializer])
        end

        before do
          stub_const(row[:expected_serializer], Class.new(Transmutation::Serializer))
        end

        it "returns an instance of #{row[:expected_serializer]}" do
          expect(lookup_serializer).to be(Object.const_get(row[:expected_serializer]))
        end
      end
    end
  end

  describe "#serialize" do
    serializer_lookup_table.each do |row|
      context "when given #{row[:context]}" do
        subject(:serialize) do
          caller.serialize(object, namespace: row[:namespace], serializer: row[:serializer])
        end

        before do
          stub_const(row[:expected_serializer], Class.new(Transmutation::Serializer))
        end

        it "returns an instance of #{row[:expected_serializer]}" do
          expect(serialize).to be_an_instance_of(Object.const_get(row[:expected_serializer]))
        end
      end
    end

    context "when given a object that does not have a serializer defined anywhere" do
      subject(:serialize) do
        caller.serialize(object)
      end

      let(:object) { Object.new }

      it "performs object's default as_json call" do
        expect(serialize).to be_an_instance_of(Transmutation::ObjectSerializer)
      end
    end
  end

  # describe "#render" do
  #   it "calls super when :json is not provided" do
  #     expect(controller.render(html: example_object)).to eq({ html: example_object })
  #   end

  #   it "calls super when :serialize is false" do
  #     expect(controller.render(json: example_object, serialize: false)).to eq(example_object)
  #   end

  #   it "calls super with the serializer for :json when :json does not respond to :map" do
  #     expect(controller.render(json: example_object)).to eq({ "first_name" => "John" })
  #   end
  # end
end
