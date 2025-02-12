require 'rails_helper'
require 'faker'

RSpec.describe "Project Field Values API", type: :request do
  let!(:project) { create(:project) } # Use let! for project
  let!(:field_definition) { create(:field_definition, project: project, field_type: "string") } # Use let! for field_definition

  describe "GET /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values", skip: true do
    it "returns all project field values for a field definition" do
      create_list(:field_value, 3, project: project, field_definition: field_definition)
      get "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values"
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)

      json_response.each do |field_value|
        expect(field_value["value"]).to be_present
        expect(field_value["project_id"]).to eq(project.id)
        expect(field_value["field_definition_id"]).to eq(field_definition.id)
      end
    end

    it "returns an empty array if no project field values exist" do
      get "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values"
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end
  end

  describe "GET /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values/:id", skip: true do
    let(:field_value) { create(:field_value, project: project, field_definition: field_definition, value: "Test Value") }

    it "returns a specific project field value" do
      get "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values/#{field_value.id}"
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to eq("Test Value")
      expect(json_response["project_id"]).to eq(project.id)
      expect(json_response["field_definition_id"]).to eq(field_definition.id)
    end

    it "returns a 404 error if the project field value doesn't exist" do
      get "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values/99999"
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values" do
    let!(:project) { create(:project) }
    let!(:field_definition) { create(:field_definition, project: project, field_type: "string") } # Optional by default
  
    it "creates a new project field value" do
      valid_attributes = attributes_for(:field_value, project: project, field_definition: field_definition).merge(project_id: project.id, field_definition_id: field_definition.id)
      expect {
        post "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values", params: { field_value: valid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
      }.to change(FieldValue, :count).by(1)
  
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to be_present
      expect(json_response["project_id"]).to eq(project.id)
      expect(json_response["field_definition_id"]).to eq(field_definition.id)
    end
  
    it "returns an error if the project field value is invalid (required field)" do
      required_field_definition = create(:field_definition, project: project, field_type: "string", required: true)
      invalid_attributes = { value: nil, project_id: project.id, field_definition_id: required_field_definition.id }
    
      post "/api/v1/projects/#{project.id}/field_definitions/#{required_field_definition.id}/field_values", params: { field_value: invalid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
    
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end
  
    it "creates a new project field value (optional field - value is nil)" do
      optional_field_definition = create(:field_definition, :optional, project: project, field_type: "string") # Optional field definition
      valid_attributes = attributes_for(:field_value, project: project, field_definition: optional_field_definition).merge(project_id: project.id, field_definition_id: optional_field_definition.id, value: nil) # Value is nil
  
      expect {
        post "/api/v1/projects/#{project.id}/field_definitions/#{optional_field_definition.id}/field_values", params: { field_value: valid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
      }.to change(FieldValue, :count).by(1)
  
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to be_nil # Value should be nil
      expect(json_response["project_id"]).to eq(project.id)
      expect(json_response["field_definition_id"]).to eq(optional_field_definition.id)
    end
  end

  describe "PATCH /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values/:id", skip: true do
    let(:field_value) { create(:field_value, project: project, field_definition: field_definition, value: "Original Value") }

    it "updates a project field value" do
      patch "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values/#{field_value.id}", params: { field_value: { value: "Updated Value" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to eq("Updated Value")
    end

    # it "returns an error if the project field value is invalid" do
    #   patch "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values/#{field_value.id}", params: { field_value: { value: nil } }.to_json, headers: { 'Content-Type': 'application/json' }
    #   expect(response).to have_http_status(422)
    #   json_response = JSON.parse(response.body)
    #   expect(json_response["errors"]).to be_present
    # end

    it "returns a 404 error if the project field value doesn't exist" do
      patch "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values/99999", params: { field_value: { value: "Updated Value" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end

  describe "DELETE /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values/:id", skip: true do
    let(:field_value) { create(:field_value, project: project, field_definition: field_definition) }

    it "deletes a project field value" do
      expect {
        delete "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values/#{field_value.id}"
      }.to change(FieldValue, :count).by(-1)
      expect(response).to have_http_status(204)
    end

    it "returns a 404 error if the project field value doesn't exist" do
      delete "/api/v1/projects/#{project.id}/field_definitions/#{field_definition.id}/field_values/99999"
      expect(response).to have_http_status(404)
    end
  end
end