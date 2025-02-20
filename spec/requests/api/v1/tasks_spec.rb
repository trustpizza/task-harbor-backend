require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :request do
  let!(:project) { create(:project) } # You'll need a Project factory
  let!(:task) { create(:task, project: project) } # You'll need a Task factory

  describe "GET /api/v1/projects/:project_id/tasks" do
    it "returns all tasks for the project" do
      get api_v1_project_tasks_url(project)
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(project.tasks.count) # Check number of tasks
      json_response.each do |task_json|
        expect(task_json["project_id"]).to eq(project.id) # Check project association
        # expect(task_json.keys).to include("id", "name", "description", "status", "due_date", "project_id", "created_at", "updated_at") # Check JSON structure
        expect(task_json.keys).to include("id", "name", "description", "due_date", "project_id", "created_at", "updated_at") # Check JSON structure
      end
    end

    context "when there are no tasks" do
      let!(:project_without_tasks) { create(:project) }
      it "returns an empty array" do
        get api_v1_project_tasks_url(project_without_tasks)
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to be_empty
      end
    end
  end

  describe "GET /api/v1/projects/:project_id/tasks/:id" do
    it "returns the requested task" do
      get api_v1_project_task_url(project, task)
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(task.id)
      expect(json_response["name"]).to eq(task.name)
      # expect(json_response.keys).to include("id", "name", "description", "status", "due_date", "project_id", "created_at", "updated_at", "fields", "field_values") # Check JSON structure, include fields and field_values
      expect(json_response.keys).to include("id", "name", "description", "due_date", "project_id", "created_at", "updated_at", "fields", "field_values") # Check JSON structure, include fields and field_values
    end

    it "returns not found if the task does not exist" do
      get api_v1_project_task_url(project, 9999) # Non-existent ID
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Task not found")
    end
  end

  describe "POST /api/v1/projects/:project_id/tasks" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "New Task", due_date: Date.tomorrow } }

      it "creates a new Task" do
        expect {
          post api_v1_project_tasks_url(project), params: { task: valid_attributes }
        }.to change(Task, :count).by(1) # Only check the count change
        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("New Task")
        expect(Date.parse(json_response["due_date"])).to eq(Date.tomorrow) # Check date format
        expect(json_response["project_id"]).to eq(project.id)
      end

      it "sets the location header" do
        post api_v1_project_tasks_url(project), params: { task: valid_attributes }
        expect(response.headers["Location"]).to eq(api_v1_project_task_url(project, Task.last))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: nil, due_date: Date.yesterday } } # Invalid due_date

      it "does not create a new Task" do
        expect {
          post api_v1_project_tasks_url(project), params: { task: invalid_attributes }
        }.to change(Task, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present # Check if errors are returned
      end
    end
  end

  describe "PATCH /api/v1/projects/:project_id/tasks/:id" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Updated Task" } }

      it "updates the requested task" do
        patch api_v1_project_task_url(project, task), params: { task: new_attributes }
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("Updated Task")
        # expect(json_response["status"]).to eq("completed")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { due_date: Date.yesterday } }

      it "does not update the task" do
        patch api_v1_project_task_url(project, task), params: { task: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end
    end

    it "returns not found if the task does not exist" do
      patch api_v1_project_task_url(project, 9999), params: { task: { name: "Test" } }
      expect(response).to have_http_status(:not_found)
       json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Task not found")
    end
  end

  describe "DELETE /api/v1/projects/:project_id/tasks/:id" do
    it "destroys the requested task" do
      expect {
        delete api_v1_project_task_url(project, task)
      }.to change { Task.count }.by(-1)
      
      expect(response).to have_http_status(:no_content)
    end

    it "returns not found if the task does not exist" do
      delete api_v1_project_task_url(project, 9999) # Non-existent ID
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Task not found")
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(Task).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed, "Destruction failed")
      end

      it "returns an error" do
        delete api_v1_project_task_url(project, task)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Destruction failed")
      end
    end
  end
end