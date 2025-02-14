require 'rails_helper'
require 'debug'

RSpec.describe FieldValue, type: :model do
  let(:field_definition) { create(:field_definition, field_type: "string") } # Default to string
  let(:field) { create(:field, field_definition: field_definition) }
  let(:field_value) { create(:field_value, field: field) }

  describe "associations" do
    it "Associates to field" do
      expect(field_value.field).to be_valid
    end

    it "Delegates field_definition to field" do
      expect(field_value.field_definition).to equal(field.field_definition)
    end
  end

  describe "validations" do
    context "required fields" do
      let(:field_definition) { create(:field_definition, field_type: "string", required: true) }

      it "is invalid without a value" do
        field_value.value = nil
        expect(field_value).to be_invalid
        expect(field_value.errors[:value]).to include("is required for this field")
      end

      it "is valid with a value" do
        field_value.value = "some value"
        expect(field_value).to be_valid
      end
    end

    context "integer fields" do
      let(:field_definition) { create(:field_definition, field_type: "integer") }

      it "is valid with an integer value" do
        field_value.value = "123"
        expect(field_value).to be_valid
      end

      it "is invalid with a non-integer value" do
        field_value.value = "abc"
        expect(field_value).to be_invalid
        expect(field_value.errors[:value]).to include("must be an integer")
      end

      it "is valid with a negative integer value" do
        field_value.value = "-123"
        expect(field_value).to be_valid
      end
    end

    context "date fields" do
      let(:field_definition) { create(:field_definition, field_type: "date") }

      it "is valid with a valid date value" do
        field_value.value = "2024-03-15"
        expect(field_value).to be_valid
      end

      it "is invalid with an invalid date value" do
        field_value.value = "invalid date"
        expect(field_value).to be_invalid
        expect(field_value.errors[:value]).to include("must be a valid date")
      end
    end

    context "boolean fields" do
      let(:field_definition) { create(:field_definition, field_type: "boolean") }

      it "is valid with a true value" do
        field_value.value = "true"
        expect(field_value).to be_valid
      end

      it "is valid with a false value" do
        field_value.value = "false"
        expect(field_value).to be_valid
      end

      it "is invalid with a non-boolean value" do
        field_value.value = "something else"
        expect(field_value).to be_invalid
        expect(field_value.errors[:value]).to include("must be true or false. Instead got something else")
      end
    end

    context "string fields" do
      let(:field_definition) { create(:field_definition, field_type: "string") }

      it "is valid with any string value" do
        field_value.value = "Any string"
        expect(field_value).to be_valid
      end

      it "is valid with a blank value if not required" do
        field_definition.required = false # Explicitly set to not required for this test
        field_value.value = ""
        expect(field_value).to be_valid
      end

      it "is invalid with a blank value if required" do
        field_definition.required = true
        field_value.value = ""
        expect(field_value).to be_invalid
      end
    end
  end

  describe "value casting" do
    # Shared examples for casting tests to reduce duplication
    shared_examples "casts value to type" do |type, valid_value, expected_value, invalid_value, error_message|
      context "when field type is #{type}" do
        let!(:field_definition) { create(:field_definition, field_type: type) }
        let!(:field) { create(:field, field_definition: field_definition) } # Rebuild the field association
        let(:field_value) { create(:field_value, field: field) }

        it "casts valid value to #{type}" do
          field_value.value = valid_value
          expect(field_value.save!).to be true # Ensure save succeeds!  This is the crucial addition.
          expect(field_value.value).to eq(expected_value)
          expect(field_value.value.class).to eq(expected_value.class) unless expected_value.nil?
        end

        it "casts blank value to nil" do
          field_value.value = ""
          field_value.save!
          expect(field_value.value).to be_nil
        end
      end
    end

    include_examples "casts value to type", "integer", "123", 123, "abc", "must be an integer"
    include_examples "casts value to type", "date", "2024-03-15", Date.new(2024, 3, 15), "invalid date", "must be a valid date"
    include_examples "casts value to type", "boolean", "true", true, "something else", "must be true or false"
    include_examples "casts value to type", "string", "test string", "test string", "", nil # String doesn't cast, nil for blank
  end
end