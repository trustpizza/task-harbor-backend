require 'rails_helper'

RSpec.describe "Project Field Definitions API", type: :request do
  let(:project) { create(:project) }

  describe "GET /api/projects/:project_id/project_field_definitions" do
    it "returns all project field definitions for a project" do
      create_list(:project_field_definition, 3, project: project)
      get "/api/projects/#{project.id}/project_field_definitions" # Added /api
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
      get "/api/projects/#{project.id}/project_field_definitions" # Added /api
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end

    it "returns a 404 error if the project doesn't exist" do
      get "/api/projects/99999/project_field_definitions" # Added /api
      expect(response).to have_http_status(404)
    end
  end

  describe "GET /api/projects/:project_id/project_field_definitions/:id" do
    let(:field_definition) { create(:project_field_definition, project: project) }

    it "returns a specific project field definition" do
      get "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}" # Added /api
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(field_definition.id)
      expect(json_response["name"]).to eq(field_definition.name)
      expect(json_response["field_type"]).to eq(field_definition.field_type)
    end

    it "returns a 404 error if the project field definition doesn't exist" do
      get "/api/projects/#{project.id}/project_field_definitions/99999" # Added /api
      expect(response).to have_http_status(404)
    end

    it "returns a 404 error if the project field definition doesn't belong to the project" do
      another_project = create(:project)
      another_field_definition = create(:project_field_definition, project: another_project)
      get "/api/projects/#{project.id}/project_field_definitions/#{another_field_definition.id}" # Added /api
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /api/projects/:project_id/project_field_definitions" do
    it "creates a new project field definition" do
      valid_attributes = { name: "New Field", field_type: "string" }

      expect {
        post "/api/projects/#{project.id}/project_field_definitions", params: valid_attributes # Added /api
      }.to change(ProjectFieldDefinition, :count).by(1)

      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("New Field")
      expect(json_response["field_type"]).to eq("string")
      expect(json_response["project_id"]).to eq(project.id)
    end

    it "returns an error if the project field definition is invalid" do
      invalid_attributes = { name: nil, field_type: "string" }

      post "/api/projects/#{project.id}/project_field_definitions", params: invalid_attributes # Added /api
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end

    it "returns a 404 error if the project doesn't exist" do
      post "/api/projects/99999/project_field_definitions", params: { name: "New Field", field_type: "string" } # Added /api
      expect(response).to have_http_status(404)
    end
  end

  describe "PATCH /api/projects/:project_id/project_field_definitions/:id" do
    let(:field_definition) { create(:project_field_definition, project: project) }

    it "updates a project field definition" do
      patch "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}", params: { name: "Updated Field" } # Added /api
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("Updated Field")
    end

    it "returns an error if the project field definition is invalid" do
      patch "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}", params: { name: nil } # Added /api
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end

    it "returns a 404 error if the project field definition doesn't exist" do
      patch "/api/projects/#{project.id}/project_field_definitions/99999", params: { name: "Updated Field" } # Added /api
      expect(response).to have_http_status(404)
    end

    it "returns a 404 error if the project field definition doesn't belong to the project" do
      another_project = create(:project)
      another_field_definition = create(:project_field_definition, project: another_project)
      patch "/api/projects/#{project.id}/project_field_definitions/#{another_field_definition.id}", params: { name: "Updated Field" } # Added /api
      expect(response).to have_http_status(404)
    end
  end

  describe "DELETE /api/projects/:project_id/project_field_definitions/:id" do
    let!(:field_definition) { create(:project_field_definition, project: project) }

    it "deletes a project field definition" do
      expect {
        delete "/api/projects/#{project.id}/project_field_definitions/#{field_definition.id}" # Added /api
      }.to change(ProjectFieldDefinition, :count).by(-1)
      expect(response).to have_http_status(204)
    end

    it "returns a 404 error if the project field definition doesn't exist" do
      delete "/api/projects/#{project.id}/project_field_definitions/99999" # Added /api
      expect(response).to have_http_status(404)
    end

    it "returns a 404 error if the project field definition doesn't belong to the project" do
      another_project = create(:project)
      another_field_definition = create(:project_field_definition, project: another_project)
      delete "/api/projects/#{project.id}/project_field_definitions/#{another_field_definition.id}" # Added /api
      expect(response).to have_http_status(404)
    end
  end
end