require 'rails_helper'
require 'faker'

RSpec.describe FieldValue, type: :model do

  describe "integration with Project and FieldDefinition" do
    it "creates a field_value and associates it with a project and field definition" do
      project = create(:project)
      field_definition = create(:field_definition, project: project, field_type: "string")

      field_value = FieldValue.new(
        project: project,
        field_definition: field_definition,
        value: "Integration Test Value"
      )

      expect(field_value).to be_valid
      expect(field_value.save).to be true  # Save the record
      expect(field_value.persisted?).to be true # Check if it's persisted in the database

      # Verify associations are set correctly
      expect(field_value.project).to eq(project)
      expect(field_value.field_definition).to eq(field_definition)

      # Retrieve from the database and verify
      retrieved_value = FieldValue.find(field_value.id)
      expect(retrieved_value.value).to eq("Integration Test Value")
      expect(retrieved_value.project).to eq(project)
      expect(retrieved_value.field_definition).to eq(field_definition)
    end


    it "updates a field_value" do
      project = create(:project)
      field_definition = create(:field_definition, project: project, field_type: "string")
      field_value = create(:field_value, project: project, field_definition: field_definition, value: "Original Value")

      field_value.value = "Updated Value"
      expect(field_value.save).to be true

      retrieved_value = FieldValue.find(field_value.id)
      expect(retrieved_value.value).to eq("Updated Value")
    end

    it "deletes a field_value" do
      project = create(:project)
      field_definition = create(:field_definition, project: project, field_type: "string")
      field_value = create(:field_value, project: project, field_definition: field_definition, value: "To be deleted")

      expect(FieldValue.exists?(field_value.id)).to be true # Check if it exists before delete

      field_value.destroy
      expect(FieldValue.exists?(field_value.id)).to be false # Check if it's gone after delete
    end

    it "cascades delete field_values when associated project is destroyed" do
        project = create(:project)
        field_definition = create(:field_definition, project: project, field_type: "string")
        field_value = create(:field_value, project: project, field_definition: field_definition)

        expect(FieldValue.exists?(field_value.id)).to be true

        project.destroy

        expect(FieldValue.exists?(field_value.id)).to be false
    end

    it "cascades delete field_values when associated field_definition is destroyed" do
        project = create(:project)
        field_definition = create(:field_definition, project: project, field_type: "string")
        field_value = create(:field_value, project: project, field_definition: field_definition)

        expect(FieldValue.exists?(field_value.id)).to be true

        field_definition.destroy

        expect(FieldValue.exists?(field_value.id)).to be false
    end
  end
end