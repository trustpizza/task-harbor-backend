require 'rails_helper'
require 'debug'


RSpec.describe "Projects API", skip: true, type: :request do
  def api_url(project_id = nil)
    base_url = "/api/v1/projects"
    project_id ? "#{base_url}/#{project_id}" : base_url
  end
  describe "GET /api/v1/projects" do
    it "returns all projects" do
      create_list(:project, 3)

      get api_url
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)

      json_response.each do |project|
        expect(project["name"]).to be_present
        expect(project["description"]).to be_present
        expect(project["due_date"]).to be_present
      end
    end

    it "returns an empty array if no projects exist" do
      get api_url
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end
  end

  describe "GET /api/v1/projects/:id" do
    let(:project) { create(:project) } # No organization needed

    it "returns a specific project" do
      get api_url(project.id)
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(project.id)
      expect(json_response["name"]).to eq(project.name)
      expect(json_response["description"]).to eq(project.description)
      expect(json_response["due_date"]).to eq(project.due_date.strftime("%Y-%m-%d"))
    end

    it "returns a 404 error if the project doesn't exist" do
      get api_url(999999)
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /api/v1/projects" do
    it "creates a new project" do
      valid_attributes = attributes_for(:project)
      expect {
        post api_url, params: { project: valid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
      }.to change(Project, :count).by(1)

      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq(valid_attributes[:name])
      expect(json_response["description"]).to eq(valid_attributes[:description])
      expect(json_response["due_date"]).to eq(valid_attributes[:due_date].strftime("%Y-%m-%d"))
    end

    it "returns an error if the project is invalid" do
      invalid_attributes = { name: nil, description: "test", due_date: Date.tomorrow }

      post api_url, params: { project: invalid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end
  end

  describe "PATCH /api/v1/projects/:id" do
    let(:project) { create(:project) } # No organization needed

    it "updates a project" do
      patch api_url(project.id), params: { project: { name: "Updated Name" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("Updated Name")
    end
    
    it "returns an error if the project is invalid" do
      patch api_url(project.id), params: { project: { name: nil } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end
    
    it "returns a 404 error if the project doesn't exist" do
      patch api_url(999999), params: { project: { name: "Updated Name" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end

  describe "DELETE /api/v1/projects/:id" do
    let!(:project) { create(:project) } # No organization needed

    it "deletes a project" do
      expect {
        delete api_url(project.id)
      }.to change(Project, :count).by(-1)
      expect(response).to have_http_status(204)
    end

    it "returns a 404 error if the project doesn't exist" do
      delete api_url(999999)
      expect(response).to have_http_status(404)
    end
  end
end