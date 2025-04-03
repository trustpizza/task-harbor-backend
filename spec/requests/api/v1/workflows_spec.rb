require 'rails_helper'

RSpec.describe "Api::V1::Workflows", type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization) }
  let!(:project) { create(:project, organization: user.organization) }
  let(:workflow) { create(:workflow, project: project) }

  describe "GET /api/v1/projects/:project_id/workflows" do
    it "returns a list of workflows for the project" do
      workflow
      get api_v1_project_workflows_url(project), headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].size).to eq(1)
    end
  end

  describe "GET /api/v1/projects/:project_id/workflows/:id" do
    it "returns the specified workflow" do
      get api_v1_project_workflow_url(project, workflow), headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]["id"]).to eq(workflow.id.to_s)
    end

    it "returns a 404 if the workflow is not found" do
      get api_v1_project_workflow_url(project, 99999), headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/projects/:project_id/workflows" do
    let(:valid_params) { { workflow: { name: "New Workflow", description: "Workflow description" } } }

    it "creates a new workflow" do
      expect {
        post api_v1_project_workflows_url(project), params: valid_params.to_json, headers: auth_header(user)
      }.to change(Workflow, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns a 422 if the parameters are invalid" do
      post api_v1_project_workflows_url(project), params: { workflow: { name: "" } }.to_json, headers: auth_header(user)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/projects/:project_id/workflows/:id" do
    let(:update_params) { { workflow: { name: "Updated Workflow" } } }.to_json

    it "updates the workflow" do
      patch api_v1_project_workflow_url(project, workflow), params: update_params.to_json, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      expect(workflow.reload.name).to eq("Updated Workflow")
    end

    it "returns a 422 if the parameters are invalid" do
      patch api_v1_project_workflow_url(project, workflow), params: { workflow: { name: "" } }.to_json, headers: auth_header(user)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/projects/:project_id/workflows/:id" do
    it "deletes the workflow" do
      workflow
      expect {
        delete api_v1_project_workflow_url(project, workflow), headers: auth_header(user)
      }.to change(Workflow, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "returns a 404 if the workflow is not found" do
      delete api_v1_project_workflow_url(project, 9999), headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
    end
  end
end
