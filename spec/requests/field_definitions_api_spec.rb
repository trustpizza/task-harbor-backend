require 'rails_helper'
require 'debug'


RSpec.describe "Field Definitions API", type: :request do
  def api_url(project_id = project.id, field_definition_id = nil)
    base_url = "/api/v1/projects/#{project_id}/field_definitions"
    field_definition_id ? "#{base_url}/#{field_definition_id}" : base_url
  end
  let!(:project) { create(:project) }

  describe "GET /api/v1/projects/:project_id/field_definitions" do
    it "returns all project field definitions for a project" do
      create_list(:field_definition, 3, project: project)
      get api_url(project.id), headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)

      json_response.each do |field_definition|
        expect(field_definition["name"]).to be_present
        expect(field_definition["field_type"]).to be_present
        expect(field_definition["project_id"]).to eq(project.id)
      end
    end

    it "returns an empty array if no project field definitions exist" do
      get api_url(project.id), headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end

    it "returns a 404 error if the project doesn't exist" do
      get api_url(999999), headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end

  describe "GET /api/v1/projects/:project_id/field_definitions/:id" do
    let(:field_definition) { create(:field_definition, project: project) }

    it "returns a specific project field definition" do
      get api_url(project.id, field_definition.id), headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(field_definition.id)
      expect(json_response["name"]).to eq(field_definition.name)
      expect(json_response["field_type"]).to eq(field_definition.field_type)
    end

    it "returns a 404 error if the project field definition doesn't exist" do
      get "/api/v1/projects/#{project.id}/field_definitions/99999", headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end

    it "returns a 404 error if the project field definition doesn't belong to the project" do
      another_project = create(:project)
      another_field_definition = create(:field_definition, project: another_project)
      get "/api/v1/projects/#{project.id}/field_definitions/#{another_field_definition.id}", headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /api/v1/projects/:project_id/field_definitions" do
    it "creates a new project field definition" do
      valid_attributes = { name: "New Field", field_type: "string" }

      expect {
        post api_url(project.id), 
             params: { field_definition: valid_attributes }.to_json,
             headers: { 'Content-Type': 'application/json' }
      }.to change(FieldDefinition, :count).by(1)
    
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("New Field")
      expect(json_response["field_type"]).to eq("string")
      expect(json_response["project_id"]).to eq(project.id)
    end

    it "returns an error if the project field definition is invalid" do
      invalid_attributes = { name: nil, field_type: "string" }

      post api_url(project.id), 
           params: { field_definition: invalid_attributes }.to_json, 
           headers: { 'Content-Type': 'application/json' }
  
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end

    it "returns a 404 error if the project doesn't exist" do
      post api_url(999999), 
           params: { name: "New Field", field_type: "string" }.to_json,
           headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end

  describe "PATCH /api/v1/projects/:project_id/field_definitions/:id" do
    let(:field_definition) { create(:field_definition, project: project) }

    it "updates a project field definition" do
      patch api_url(project.id, field_definition.id), 
            params: { field_definition: { name: "Updated Field" } }.to_json, 
            headers: { 'Content-Type': 'application/json' }

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("Updated Field")
    end

    it "returns an error if the project field definition is invalid" do
      patch api_url(project.id, field_definition.id), 
            params: { name: nil }.to_json, 
            headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end

    it "returns a 404 error if the project field definition doesn't exist" do
      patch "/api/v1/projects/#{project.id}/field_definitions/99999", 
            params: { name: "Updated Field" }.to_json, 
            headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end

    it "returns a 404 error if the project field definition doesn't belong to the project" do
      another_project = create(:project)
      another_field_definition = create(:field_definition, project: another_project)
      patch "/api/v1/projects/#{project.id}/field_definitions/#{another_field_definition.id}", 
            params: { name: "Updated Field" }.to_json, 
            headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end

  describe "DELETE /api/v1/projects/:project_id/field_definitions/:id" do
    let!(:field_definition) { create(:field_definition, project: project) }

    it "deletes a project field definition" do
      expect {
        delete api_url(project.id, field_definition.id), headers: { 'Content-Type': 'application/json' }
      }.to change(FieldDefinition, :count).by(-1)
      expect(response).to have_http_status(204)
    end

    it "returns a 404 error if the project field definition doesn't exist" do
      delete "/api/v1/projects/#{project.id}/field_definitions/99999", headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end

    it "returns a 404 error if the project field definition doesn't belong to the project" do
      another_project = create(:project)
      another_field_definition = create(:field_definition, project: another_project)
      delete "/api/v1/projects/#{project.id}/field_definitions/#{another_field_definition.id}", headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end
end
