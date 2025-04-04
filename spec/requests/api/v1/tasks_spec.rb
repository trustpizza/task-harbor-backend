require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization) }
  let!(:project) { create(:project, organization: organization) }
  let!(:workflow) { create(:workflow, organization: organization) }
  let!(:project_task) { create(:task, taskable: project) }
  let!(:workflow_task) { create(:task, taskable: workflow) }

  describe "GET /api/v1/projects/:project_id/tasks" do
    it "returns all tasks for the project" do
      get api_v1_project_tasks_url(project), headers: auth_header(user)
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response["data"].length).to eq(project.tasks.count)
      json_response["data"].each do |task_json|
        expect(task_json["attributes"].keys).to include("name", "description", "due_date", "created_at", "updated_at")
      end
    end
  end

  describe "GET /api/v1/workflows/:workflow_id/tasks" do
    it "returns all tasks for the workflow" do
      get api_v1_workflow_tasks_url(workflow), headers: auth_header(user)
      expect(response).to have_http_status(:success)
      
      json_response = JSON.parse(response.body)
      expect(json_response["data"].length).to eq(workflow.tasks.count)
      json_response["data"].each do |task_json|
        expect(task_json["attributes"].keys).to include("name", "description", "due_date", "created_at", "updated_at")
      end
    end
  end

  describe "POST /api/v1/projects/:project_id/tasks" do
    let(:valid_attributes) { { task: { name: "New Task", due_date: Time.zone.tomorrow } } }

    it "creates a new task for the project" do
      expect {
        post api_v1_project_tasks_url(project), params: valid_attributes.to_json, headers: auth_header(user)
      }.to change(Task, :count).by(1)
      expect(response).to have_http_status(:created)

      json_response = JSON.parse(response.body)
      expect(json_response["data"]["attributes"]["name"]).to eq("New Task")
      expect(Date.parse(json_response["data"]["attributes"]["due_date"])).to eq(Time.zone.tomorrow)
    end
  end

  describe "POST /api/v1/workflows/:workflow_id/tasks" do
    let(:valid_attributes) { { task: { name: "New Task", due_date: Time.zone.tomorrow } } }

    it "creates a new task for the workflow" do
      expect {
        post api_v1_workflow_tasks_url(workflow), params: valid_attributes.to_json, headers: auth_header(user)
      }.to change(Task, :count).by(1)
      expect(response).to have_http_status(:created)

      json_response = JSON.parse(response.body)
      expect(json_response["data"]["attributes"]["name"]).to eq("New Task")
      expect(Date.parse(json_response["data"]["attributes"]["due_date"])).to eq(Time.zone.tomorrow)
    end
  end

  describe "PATCH /api/v1/projects/:project_id/tasks/:id" do
    let(:new_attributes) { { task: { name: "Updated Task" } } }

    it "updates the task for the project" do
      patch api_v1_project_task_url(project, project_task), params: new_attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response["data"]["attributes"]["name"]).to eq("Updated Task")
    end
  end

  describe "PATCH /api/v1/workflows/:workflow_id/tasks/:id" do
    let(:new_attributes) { { task: { name: "Updated Task" } } }

    it "updates the task for the workflow" do
      patch api_v1_workflow_task_url(workflow, workflow_task), params: new_attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response["data"]["attributes"]["name"]).to eq("Updated Task")
    end
  end

  describe "DELETE /api/v1/projects/:project_id/tasks/:id" do
    it "deletes the task for the project" do
      expect {
        delete api_v1_project_task_url(project, project_task), headers: auth_header(user)
      }.to change(Task, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "DELETE /api/v1/workflows/:workflow_id/tasks/:id" do
    it "deletes the task for the workflow" do
      expect {
        delete api_v1_workflow_task_url(workflow, workflow_task), headers: auth_header(user)
      }.to change(Task, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end