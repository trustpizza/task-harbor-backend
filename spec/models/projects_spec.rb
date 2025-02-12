require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      project = build(:project)
      expect(project).to be_valid
    end

    it "is not valid without a name" do
      project = build(:project, name: nil)
      expect(project).to_not be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end

    it "is not valid without a description" do
      project = build(:project, description: nil)
      expect(project).to_not be_valid
      expect(project.errors[:description]).to include("can't be blank")
    end

    it "is not valid without a due_date" do
      project = build(:project, due_date: nil)
      expect(project).to_not be_valid
      expect(project.errors[:due_date]).to include("can't be blank")
    end

    it "is not valid with a due_date in the past" do
      project = build(:project, due_date: Time.zone.today - 2.days) # Use 2 days ago
      expect(project).to_not be_valid
      expect(project.errors[:due_date]).to include("must be greater than or equal to #{Time.zone.today}")
    end
  end

  describe "associations" do
    it "has many project_field_definitions" do
      project = create(:project)
      create(:project_field_definition, project: project)
      expect(project.project_field_definitions.count).to eq(1)
    end

    it "has many project_field_values" do
      project = create(:project)
      field_definition = create(:project_field_definition, project: project)
      create(:project_field_value, project: project, project_field_definition: field_definition)
      expect(project.project_field_values.count).to eq(1)
    end
  end

  describe "scopes" do
    describe "upcoming" do
      it "returns projects with due dates in the future" do
        create(:project, due_date: Date.tomorrow)
        build(:project, due_date: Date.yesterday)
        expect(Project.upcoming.count).to eq(1)
      end
    end
    describe "overdue" do
      it "returns projects with due dates in the past" do
        create(:project, due_date: Date.tomorrow)  # Should NOT be included
        create(:project, due_date: Time.zone.today)     # Should NOT be included
        # Bypass validation to create an overdue project
        overdue_project = build(:project, due_date: Date.yesterday)
        overdue_project.save(validate: false) 
  
        expect(Project.overdue.count).to eq(1)
        expect(Project.overdue).to include(overdue_project)
      end
    end
  end
  
end


RSpec.describe "Projects API", type: :request do
  describe "GET /api/v1/projects" do
    it "returns all projects" do
      create_list(:project, 3)
      get "/api/v1/projects"
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
      get "/api/v1/projects"
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end
  end

  describe "GET /api/v1/projects/:id" do
    let(:project) { create(:project) } # No organization needed

    it "returns a specific project" do
      get "/api/v1/projects/#{project.id}"
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(project.id)
      expect(json_response["name"]).to eq(project.name)
      expect(json_response["description"]).to eq(project.description)
      expect(json_response["due_date"]).to eq(project.due_date.strftime("%Y-%m-%d"))
    end

    it "returns a 404 error if the project doesn't exist" do
      get "/api/v1/projects/99999"
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /api/v1/projects" do
    it "creates a new project" do
      valid_attributes = attributes_for(:project)
      expect {
        post "/api/v1/projects", params: { project: valid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
      }.to change(Project, :count).by(1)

      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq(valid_attributes[:name])
      expect(json_response["description"]).to eq(valid_attributes[:description])
      expect(json_response["due_date"]).to eq(valid_attributes[:due_date].strftime("%Y-%m-%d"))
    end

    it "returns an error if the project is invalid" do
      invalid_attributes = { name: nil, description: "test", due_date: Date.tomorrow }

      post "/api/v1/projects", params: { project: invalid_attributes }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end
  end

  describe "PATCH /api/v1/projects/:id" do
    let(:project) { create(:project) } # No organization needed

    it "updates a project" do
      patch "/api/v1/projects/#{project.id}", params: { project: { name: "Updated Name" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("Updated Name")
    end
    
    it "returns an error if the project is invalid" do
      patch "/api/v1/projects/#{project.id}", params: { project: { name: nil } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(422)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end
    
    it "returns a 404 error if the project doesn't exist" do
      patch "/api/v1/projects/99999", params: { project: { name: "Updated Name" } }.to_json, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(404)
    end
  end

  describe "DELETE /api/v1/projects/:id" do
    let!(:project) { create(:project) } # No organization needed

    it "deletes a project" do
      expect {
        delete "/api/v1/projects/#{project.id}"
      }.to change(Project, :count).by(-1)
      expect(response).to have_http_status(204)
    end

    it "returns a 404 error if the project doesn't exist" do
      delete "/api/v1/projects/99999"
      expect(response).to have_http_status(404)
    end
  end
end