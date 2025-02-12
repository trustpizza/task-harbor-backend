require 'rails_helper'
require 'faker'
require 'debug'

RSpec.describe "Project Field Values API", type: :request do
  let!(:project) { create(:project) }
  let!(:field_definition) { create(:field_definition, project: project, field_type: "string") }

  def get_api(path = "")
    "/api/v1/projects/#{project.id}/field_values#{path}"
  end

  describe "GET /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values" do
    it "returns all project field values for a field definition" do
      create_list(:field_value, 3, project: project, field_definition: field_definition)
      get get_api
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
      get get_api
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end
  end

  describe "GET /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values/:id" do
    let!(:field_value) { create(:field_value, project: project, field_definition: field_definition, value: "Test Value") }

    it "returns a specific project field value" do
      get get_api("/#{field_value.id}")
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to eq("Test Value")
      expect(json_response["project_id"]).to eq(project.id)
      expect(json_response["field_definition_id"]).to eq(field_definition.id)
    end

    it "returns a 404 error if the project field value doesn't exist" do
      get get_api("/99999")
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values" do
    let!(:project) { create(:project) }
    let!(:field_definition) { create(:field_definition, field_type: "integer", project: project) } # Associate with the project

    it "creates a new project field value" do
      # Explicitly create the project and field_definition using let!
      
      # IMPORTANT: Use the field_definition created in the test
      values_array = [{ field_definition_id: field_definition.id, value: 1 }]
      expect {
        post get_api, params: { values: values_array }.to_json, headers: { 'Content-Type': 'application/json' }
      }.to change(FieldValue, :count).by(1)
    
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
    
      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(1)
    
      created_field_value = json_response.first
      expect(created_field_value["value"]).to be_present
      expect(created_field_value["project_id"]).to eq(project.id)
      expect(created_field_value["field_definition_id"]).to eq(field_definition.id)
    end

  end

  describe "PATCH /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values/:id" do
    let!(:field_value) { create(:field_value, project: project, field_definition: field_definition, value: "Original Value") }

    it "updates a project field value" do
      patch get_api("/#{field_value.id}"), params: { field_value: { value: "Updated Value" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["value"]).to eq("Updated Value")
    end

    it "returns a 404 error if the project field value doesn't exist" do
      patch get_api("/99999"), params: { field_value: { value: "Updated Value" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end

  describe "DELETE /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values/:id" do
    let!(:field_value) { create(:field_value, project: project, field_definition: field_definition) }

    it "deletes a project field value" do
      expect {
        delete get_api("/#{field_value.id}")
      }.to change(FieldValue, :count).by(-1)
      expect(response).to have_http_status(204)
    end

    it "returns a 404 error if the project field value doesn't exist" do
      delete get_api("/99999")
      expect(response).to have_http_status(404)
    end
  end
end