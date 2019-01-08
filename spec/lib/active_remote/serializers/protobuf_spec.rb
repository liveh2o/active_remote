require 'spec_helper'

describe ActiveRemote::Serializers::Protobuf::Fields do
  describe ".from_attributes" do
    let(:ready_value) { { :records => [ { :name => 'Cool Post', :errors => [ { :message => 'Boom!' } ] } ] } }
    let(:value) { { :records => { :name => 'Cool Post', :errors => { :message => 'Boom!' } } } }

    it "gets protobuf-ready fields from attributes" do
      expect(described_class.from_attributes(Generic::Remote::Posts, value)).to eq ready_value
    end
  end
end

describe ActiveRemote::Serializers::Protobuf::Field do
  describe ".from_attribute" do
    context "when field is a repeated message" do
      let(:field) { Generic::Remote::Posts.get_field(:records) }

      context "and the value is not an array" do
        let(:ready_value) { [ { :name => 'Cool Post', :errors => [ { :message => 'Boom!' } ] } ] }
        let(:value) { { :name => 'Cool Post', :errors => { :message => 'Boom!' } } }

        it "gets protobuf-ready fields from the value" do
          expect(described_class.from_attribute(field, value)).to eq ready_value
        end
      end
    end

    context "when field is a message" do
      let(:field) { Generic::Remote::Post.get_field(:category) }

      context "and value is a hash" do
        let(:ready_value) { { :name => 'Film', :errors => [ { :message => 'Boom!' } ] } }
        let(:value) { { :name => 'Film', :errors => { :message => 'Boom!' } } }

        it "gets protobuf-ready fields from the value" do
          expect(described_class.from_attribute(field, value)).to eq ready_value
        end
      end
    end

    context "when field is repeated" do
      let(:field) { Generic::Remote::PostRequest.get_field(:name) }

      context "and the value is not an array" do
        let(:ready_value) { [ 'Cool Post' ] }
        let(:value) { 'Cool Post' }

        it "gets protobuf-ready fields from the value" do
          expect(described_class.from_attribute(field, value)).to eq ready_value
        end
      end
    end

    # TODO: Find a better way to write this. It works for now, but it's not
    # very clear and is hard to track down since failures don't include a
    # description.
    #
    # TODO: Consider adding specific specs for typecasting dates to integers
    # or strings since that's what prompted the re-introduction of the
    # typecasting.
    #
    context "when typecasting fields" do
      let(:string_value) { double(:string, :to_s => '') }

      def typecasts(field, conversion)
        field = Serializer.get_field(field, true)
        expect(described_class.from_attribute(field, conversion.first[0])).to eq conversion.first[1]
      end

      it { typecasts(:bool_field, '0' => false) }
      it { typecasts(:bytes_field, string_value => '') }
      it { typecasts(:double_field, 0 => 0.0) }
      it { typecasts(:fixed32_field, '0' => 0) }
      it { typecasts(:fixed64_field, '0' => 0) }
      it { typecasts(:float_field, 0 => 0.0) }
      it { typecasts(:int32_field, '0' => 0) }
      it { typecasts(:int64_field, '0' => 0) }
      it { typecasts(:sfixed32_field, '0' => 0) }
      it { typecasts(:sfixed64_field, '0' => 0) }
      it { typecasts(:sint32_field, '0' => 0) }
      it { typecasts(:sint64_field, '0' => 0) }
      it { typecasts(:string_field, string_value => '') }
      it { typecasts(:uint32_field, '0' => 0) }
      it { typecasts(:uint64_field, '0' => 0) }
      it { typecasts(:enum_field, 0 => 0) }
    end
  end
end
