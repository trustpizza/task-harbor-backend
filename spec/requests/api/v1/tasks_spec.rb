require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization) }
  let!(:project) { create(:project, organization: organization) }
  let!(:task) { create(:task, project: project) }

  describe "GET /api/v1/projects/:project_id/tasks" do
    it "returns all tasks for the project" do
      get api_v1_project_tasks_url(project), headers: auth_header(user)
      expect(response).to have_http_status(:success)
      
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(project.tasks.count)
      json_response["data"].each do |task_json|
        expect(task_json["attributes"].keys).to include("name", "description", "due_date", "created_at", "updated_at")
      end
    end

    context "when there are no tasks" do
      let!(:project_without_tasks) { create(:project, organization: organization) }
      it "returns an empty array" do
        get api_v1_project_tasks_url(project_without_tasks), headers: auth_header(user)
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["data"]).to be_empty
      end
    end
  end

  describe "GET /api/v1/projects/:project_id/tasks/:id" do
    it "returns the requested task" do
      get api_v1_project_task_url(project, task), headers: auth_header(user)
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response["data"]["id"].to_i).to eq(task.id)
      expect(json_response["data"]["attributes"]["name"]).to eq(task.name)
      expect(json_response["data"]["attributes"].keys).to include("name", "description", "due_date", "created_at", "updated_at")
      expect(json_response["data"]["relationships"].keys).to include("fields", "field_values")
    end

    it "returns not found if the task does not exist" do
      get api_v1_project_task_url(project, 9999), headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Task not found")
    end
  end

  describe "POST /api/v1/projects/:project_id/tasks" do
    context "with valid parameters" do
      let(:valid_attributes) { { task: { name: "New Task", due_date: Date.tomorrow, project_id: project.id.to_s } } }

      it "creates a new Task" do
        expect {
          post api_v1_project_tasks_url(project), params: valid_attributes.to_json, headers: auth_header(user)
        }.to change(Task, :count).by(1)
        expect(response).to have_http_status(:created)
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["attributes"]["name"]).to eq("New Task")
        expect(Date.parse(json_response["data"]["attributes"]["due_date"])).to eq(Date.tomorrow)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { task: { name: nil, due_date: Date.yesterday, project_id: project.id.to_s } } }

      it "does not create a new Task" do
        expect {
          post api_v1_project_tasks_url(project), params: invalid_attributes.to_json, headers: auth_header(user)
        }.to change(Task, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end
    end
  end

  describe "PATCH /api/v1/projects/:project_id/tasks/:id" do
    context "with valid parameters" do
      let(:new_attributes) { { task: { name: "Updated Task" } } }

      it "updates the requested task" do
        patch api_v1_project_task_url(project, task), params: new_attributes.to_json, headers: auth_header(user)
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response["data"]["attributes"]["name"]).to eq("Updated Task")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { task: { due_date: Date.yesterday } } }
      it "does not update the task" do
        patch api_v1_project_task_url(project, task), params: invalid_attributes.to_json, headers: auth_header(user)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end
    end

    it "returns not found if the task does not exist" do
      patch api_v1_project_task_url(project, 9999), params: { task: { name: "Test" } }.to_json, headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Task not found")
    end
  end

  describe "DELETE /api/v1/projects/:project_id/tasks/:id" do
    it "destroys the requested task" do
      expect {
        delete api_v1_project_task_url(project, task), headers: auth_header(user)
      }.to change { Task.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns not found if the task does not exist" do
      delete api_v1_project_task_url(project, 9999), headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Task not found")
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(Task).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed, "Destruction failed")
      end

      it "returns an error" do
        delete api_v1_project_task_url(project, task), headers: auth_header(user)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Destruction failed")
      end
    end
  end
end