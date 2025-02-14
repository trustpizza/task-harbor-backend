require 'rails_helper'

RSpec.describe FieldDefinition,  type: :model do
  describe "validations" do
    context "name" do
      it "is invalid if blank" do
        field_definition = build(:field_definition, name: nil) # Use FactoryBot if you have it
        expect(field_definition).to be_invalid
        expect(field_definition.errors[:name]).to include("can't be blank")
      end

      it "is invalid if too long" do
        field_definition = build(:field_definition, name: "a" * 256)
        expect(field_definition).to be_invalid
        expect(field_definition.errors[:name]).to include("is too long (maximum is 255 characters)")
      end
    end

    context "field_type" do
      it "is invalid if blank" do
        field_definition = build(:field_definition, field_type: nil) # Or FieldDefinition.new(field_type: nil)
        expect(field_definition).to be_invalid
        expect(field_definition.errors[:field_type]).to include("can't be blank")
      end

      it "is invalid if not in the allowed list" do
        field_definition = build(:field_definition, field_type: "invalid_type")
        expect(field_definition).to be_invalid
        expect(field_definition.errors[:field_type]).to include("is not included in the list")
      end

      it "is valid if field_type is 'string'" do
        field_definition = build(:field_definition, field_type: "string")
        expect(field_definition).to be_valid
      end

      it "is valid if field_type is 'integer'" do
        field_definition = build(:field_definition, field_type: "integer")
        expect(field_definition).to be_valid
      end

      it "is valid if field_type is 'date'" do
        field_definition = build(:field_definition, field_type: "date")
        expect(field_definition).to be_valid
      end

      it "is valid if field_type is 'boolean'" do
        field_definition = build(:field_definition, field_type: "boolean")
        expect(field_definition).to be_valid
      end

      # it "is valid if field_type is 'dropdown'" do
      #   field_definition = build(:field_definition, field_type: "dropdown")
      #   expect(field_definition).to be_valid
      # end

      # it "is valid if field_type is 'text'" do
      #   field_definition = build(:field_definition, field_type: "text")
      #   expect(field_definition).to be_valid
      # end
    end

    context "options_format" do
      it "is valid if options are blank" do
        field_definition = build(:field_definition, options: nil)
        expect(field_definition).to be_valid

        field_definition = build(:field_definition, options: "")
        expect(field_definition).to be_valid
      end

      it "is invalid if options are not valid JSON" do
        field_definition = build(:field_definition, options: "invalid json")
        expect(field_definition).to be_invalid
        expect(field_definition.errors[:options]).to include("must be valid JSON")
      end

      # context "dropdown" do
      #   it "is invalid if options are not a JSON array of strings" do
      #     field_definition = build(:field_definition, field_type: "dropdown", options: '{"a": 1}') # JSON object
      #     expect(field_definition).to be_invalid
      #     expect(field_definition.errors[:options]).to include("must be a JSON array of strings for dropdowns")

      #     field_definition = build(:field_definition, field_type: "dropdown", options: '["a", 1]') # Array with non-string
      #     expect(field_definition).to be_invalid
      #     expect(field_definition.errors[:options]).to include("must be a JSON array of strings for dropdowns")
      #   end

      #   it "is valid if options are a JSON array of strings" do
      #       field_definition = build(:field_definition, field_type: "dropdown", options: '["a", "b"]')
      #       expect(field_definition).to be_valid
      #   end
      # end

      context "integer" do
        it "is invalid if options are not a JSON hash with min and max integers" do
          field_definition = build(:field_definition, field_type: "integer", options: '["a", "b"]')
          expect(field_definition).to be_invalid
          expect(field_definition.errors[:options]).to include("must be a JSON Hash of min and max for integer type")

          field_definition = build(:field_definition, field_type: "integer", options: '{"min": "a", "max": "b"}') # Non-integer values
          expect(field_definition).to be_invalid
          expect(field_definition.errors[:options]).to include("must be a JSON Hash of min and max for integer type")
        end

        it "is valid if options are a JSON hash with min and max integers" do
          field_definition = build(:field_definition, field_type: "integer", options: '{"min": -10, "max": 10}')
          expect(field_definition).to be_valid
        end
      end
    end
  end

  # Example of testing associations (if needed)
  describe "associations" do

    it "has many field" do
      field_definition = create(:field_definition)
      create_list(:field, 3, field_definition: field_definition)
      expect(field_definition.fields.count).to eq(3)
    end

  end
end