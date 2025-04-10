require 'rails_helper'

RSpec.describe "Api::V1::ProjectFilters", type: :request do
  let(:org) { create(:organization) }
  let(:user) { create(:user, organization: org) }
  let!(:project1) do
    project = build(:project, organization: org, project_manager: user, is_complete: false, due_date: Date.new(2024, 12, 30))
    project.save(validate: false)
    project
  end    
  let(:project2) { create(:project, organization: org, project_manager: user, is_complete: true, due_date: Time.zone.tomorrow) }
  let(:field_definition) { create(:field_definition, field_type: "string", name: "Urgency") }

  before do
    create(:field, fieldable: project1, field_definition: field_definition, value: "Urgent")
  end

  describe "GET /api/v1/projects with ad-hoc filters" do
    it "returns only incomplete projects with attribute filter" do
      get api_v1_projects_url, headers: auth_header(user), params: {
        filter: {
          logic: "AND",
          conditions: [
            {
              type: "attribute",
              attribute: "is_complete",
              operator: "eq",
              value: false
            }
          ]
        }
      }

      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)["data"]
      expect(data.size).to eq(1)
      expect(data.first["id"]).to eq(project1.id.to_s)
    end

    it "returns only projects with 'Urgent' field value" do
      # debugger
      get api_v1_projects_url, headers: auth_header(user), params: {
        filter: {
          logic: "AND",
          conditions: [
            {
              type: "field",
              field_definition_id: field_definition.id,
              operator: "eq",
              value: "Urgent"
            }
          ]
        }
      }

      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)["data"]
      expect(data.size).to eq(1)
      expect(data.first["id"]).to eq(project1.id.to_s)
    end

    it "returns no projects if filter condition doesn't match" do
      get api_v1_projects_url, headers: auth_header(user), params: {
        filter: {
          logic: "AND",
          conditions: [
            {
              type: "attribute",
              attribute: "name",
              operator: "eq",
              value: "Nonexistent"
            }
          ]
        }
      }

      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)["data"]
      expect(data).to be_empty
    end
  end
end
