require 'rails_helper'
require 'faker'


RSpec.describe ProjectFieldValue, type: :model, skip: true do

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

RSpec.describe "Project Field Values API", type: :request do
  let!(:project) { create(:project) } # Use let! for project
  let!(:field_definition) { create(:project_field_definition, project: project, field_type: "string") } # Use let! for field_definition

  describe "GET /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values", skip: true do
    it "returns all project field values for a field definition" do
      create_list(:project_field_value, 3, project: project, project_field_definition: field_definition)
      get "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values"
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)

      json_response.each do |field_value|
        expect(field_value["value"]).to be_present
        expect(field_value["project_id"]).to eq(project.id)
        expect(field_value["project_field_definition_id"]).to eq(field_definition.id)
      end
    end

    it "returns an empty array if no project field values exist" do
      get "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values"
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end
  end

  describe "GET /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values/:id", skip: true do
    let(:project_field_value) { create(:project_field_value, project: project, project_field_definition: field_definition, value: "Test Value") }

    it "returns a specific project field value" do
      get "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values/#{project_field_value.id}"
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to eq("Test Value")
      expect(json_response["project_id"]).to eq(project.id)
      expect(json_response["project_field_definition_id"]).to eq(field_definition.id)
    end

    it "returns a 404 error if the project field value doesn't exist" do
      get "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values/99999"
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values" do
    let!(:project) { create(:project) }
    let!(:field_definition) { create(:project_field_definition, project: project, field_type: "string") } # Optional by default
  
    it "creates a new project field value" do
      valid_attributes = attributes_for(:project_field_value, project: project, project_field_definition: field_definition).merge(project_id: project.id, project_field_definition_id: field_definition.id)
      expect {
        post "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values", params: { project_field_value: valid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
      }.to change(ProjectFieldValue, :count).by(1)
  
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to be_present
      expect(json_response["project_id"]).to eq(project.id)
      expect(json_response["project_field_definition_id"]).to eq(field_definition.id)
    end
  
    it "returns an error if the project field value is invalid (required field)" do
      required_field_definition = create(:project_field_definition, project: project, field_type: "string", required: true)
      invalid_attributes = { value: nil, project_id: project.id, project_field_definition_id: required_field_definition.id }
    
      post "/api/projects/#{project.id}/project_field_definitions/#{required_field_definition.id}/project_field_values", params: { project_field_value: invalid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
    
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end
  
    it "creates a new project field value (optional field - value is nil)" do
      optional_field_definition = create(:project_field_definition, :optional, project: project, field_type: "string") # Optional field definition
      valid_attributes = attributes_for(:project_field_value, project: project, project_field_definition: optional_field_definition).merge(project_id: project.id, project_field_definition_id: optional_field_definition.id, value: nil) # Value is nil
  
      expect {
        post "/api/projects/#{project.id}/project_field_definitions/#{optional_field_definition.id}/project_field_values", params: { project_field_value: valid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
      }.to change(ProjectFieldValue, :count).by(1)
  
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to be_nil # Value should be nil
      expect(json_response["project_id"]).to eq(project.id)
      expect(json_response["project_field_definition_id"]).to eq(optional_field_definition.id)
    end
  end

  describe "PATCH /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values/:id", skip: true do
    let(:project_field_value) { create(:project_field_value, project: project, project_field_definition: field_definition, value: "Original Value") }

    it "updates a project field value" do
      patch "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values/#{project_field_value.id}", params: { project_field_value: { value: "Updated Value" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to eq("Updated Value")
    end

    # it "returns an error if the project field value is invalid" do
    #   patch "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values/#{project_field_value.id}", params: { project_field_value: { value: nil } }.to_json, headers: { 'Content-Type': 'application/json' }
    #   expect(response).to have_http_status(422)
    #   json_response = JSON.parse(response.body)
    #   expect(json_response["errors"]).to be_present
    # end

    it "returns a 404 error if the project field value doesn't exist" do
      patch "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values/99999", params: { project_field_value: { value: "Updated Value" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end

  describe "DELETE /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values/:id", skip: true do
    let(:project_field_value) { create(:project_field_value, project: project, project_field_definition: field_definition) }

    it "deletes a project field value" do
      expect {
        delete "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values/#{project_field_value.id}"
      }.to change(ProjectFieldValue, :count).by(-1)
      expect(response).to have_http_status(204)
    end

    it "returns a 404 error if the project field value doesn't exist" do
      delete "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}/project_field_values/99999"
      expect(response).to have_http_status(404)
    end
  end
end