require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization) }
  
  let(:valid_attributes) {
    { project: {
        name: 'Test Project',
        description: 'Test Description',
        due_date: Time.zone.tomorrow,
        project_manager_id: user.id.to_s
      }
    }
  }

  let(:invalid_attributes) {
    { project: {
        name: nil,
        description: nil,
        due_date: nil,
        project_manager_id: user.id.to_s
      }
    }
  }

  describe 'GET /api/v1/projects' do
    it 'returns a list of projects' do
      organization.projects.create(valid_attributes[:project])
      get api_v1_projects_url, headers: auth_header(user) # Use helper
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe 'GET /api/v1/projects/:id' do
    it 'returns a single project' do
      project = organization.projects.create(valid_attributes[:project])
      get api_v1_project_url(project), headers: auth_header(user) # Use helper
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["data"]["attributes"]["name"]).to eq('Test Project')
    end

    it 'returns a 404 if project is not found' do
      get api_v1_project_url(999), headers: auth_header(user) # Use helper
      expect(response).to have_http_status(404)
      expect(JSON.parse(response.body)['error']).to eq('Project not found')
    end
  end

  describe 'POST /api/v1/projects' do
    context 'with valid parameters' do
      it 'creates a new project' do
        expect {
          post api_v1_projects_url, params: valid_attributes.to_json, headers: auth_header(user) # Use helper
        }.to change(Project, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'renders a JSON response with the new project' do
        post api_v1_projects_url, params: valid_attributes.to_json, headers: auth_header(user) # Use helper
        expect(JSON.parse(response.body)["data"]["attributes"]["name"]).to eq('Test Project')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new project' do
        expect {
          post api_v1_projects_url, params: invalid_attributes.to_json, headers: auth_header(user) # Use helper
        }.to change(Project, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders a JSON response with errors for the new project' do
        post api_v1_projects_url, params: invalid_attributes.to_json, headers: auth_header(user) # Use helper
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'PATCH /api/v1/projects/:id' do
    let(:new_attributes) { { project: { name: 'Updated Project' } } }
    context 'with valid parameters' do
      it 'updates the requested project' do
        project = organization.projects.create(valid_attributes[:project])
        patch api_v1_project_url(project), params: new_attributes.to_json, headers: auth_header(user) # Use helper
        project.reload
        expect(project.name).to eq('Updated Project')
        expect(response).to have_http_status(200)
      end

      it 'renders a JSON response with the project' do
        project = organization.projects.create(valid_attributes[:project])
        patch api_v1_project_url(project), params: new_attributes.to_json, headers: auth_header(user) # Use helper
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["data"]["attributes"]["name"]).to eq('Updated Project')
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the project' do
        project = organization.projects.create(valid_attributes[:project])
        patch api_v1_project_url(project), params: invalid_attributes.to_json, headers: auth_header(user) # Use helper
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    it 'destroys the requested project' do
      project = organization.projects.create(valid_attributes[:project])
      expect {
        delete api_v1_project_url(project), headers: auth_header(user) # Use helper
      }.to change(Project, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 422 when destroy fails' do
      project = organization.projects.create(valid_attributes[:project])
      allow_any_instance_of(Project).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new("Destroy Failed"))

      delete api_v1_project_url(project), headers: auth_header(user) # Use helper
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq("Destroy Failed")
    end
  end
end