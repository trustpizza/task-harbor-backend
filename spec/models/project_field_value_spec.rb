require 'rails_helper'
require 'faker'


RSpec.describe ProjectFieldValue, type: :model do
  # ... (Existing model tests from previous response remain here) ...

  describe "integration with Project and ProjectFieldDefinition" do
    it "creates a project_field_value and associates it with a project and field definition" do
      project = create(:project)
      field_definition = create(:project_field_definition, project: project, field_type: "string")

      project_field_value = ProjectFieldValue.new(
        project: project,
        project_field_definition: field_definition,
        value: "Integration Test Value"
      )

      expect(project_field_value).to be_valid
      expect(project_field_value.save).to be true  # Save the record
      expect(project_field_value.persisted?).to be true # Check if it's persisted in the database

      # Verify associations are set correctly
      expect(project_field_value.project).to eq(project)
      expect(project_field_value.project_field_definition).to eq(field_definition)

      # Retrieve from the database and verify
      retrieved_value = ProjectFieldValue.find(project_field_value.id)
      expect(retrieved_value.value).to eq("Integration Test Value")
      expect(retrieved_value.project).to eq(project)
      expect(retrieved_value.project_field_definition).to eq(field_definition)
    end


    it "updates a project_field_value" do
      project = create(:project)
      field_definition = create(:project_field_definition, project: project, field_type: "string")
      project_field_value = create(:project_field_value, project: project, project_field_definition: field_definition, value: "Original Value")

      project_field_value.value = "Updated Value"
      expect(project_field_value.save).to be true

      retrieved_value = ProjectFieldValue.find(project_field_value.id)
      expect(retrieved_value.value).to eq("Updated Value")
    end

    it "deletes a project_field_value" do
      project = create(:project)
      field_definition = create(:project_field_definition, project: project, field_type: "string")
      project_field_value = create(:project_field_value, project: project, project_field_definition: field_definition, value: "To be deleted")

      expect(ProjectFieldValue.exists?(project_field_value.id)).to be true # Check if it exists before delete

      project_field_value.destroy
      expect(ProjectFieldValue.exists?(project_field_value.id)).to be false # Check if it's gone after delete
    end

    it "cascades delete project_field_values when associated project is destroyed" do
        project = create(:project)
        field_definition = create(:project_field_definition, project: project, field_type: "string")
        project_field_value = create(:project_field_value, project: project, project_field_definition: field_definition)

        expect(ProjectFieldValue.exists?(project_field_value.id)).to be true

        project.destroy

        expect(ProjectFieldValue.exists?(project_field_value.id)).to be false
    end

    it "cascades delete project_field_values when associated project_field_definition is destroyed" do
        project = create(:project)
        field_definition = create(:project_field_definition, project: project, field_type: "string")
        project_field_value = create(:project_field_value, project: project, project_field_definition: field_definition)

        expect(ProjectFieldValue.exists?(project_field_value.id)).to be true

        field_definition.destroy

        expect(ProjectFieldValue.exists?(project_field_value.id)).to be false
    end
  end
end