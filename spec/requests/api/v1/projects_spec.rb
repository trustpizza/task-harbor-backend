require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :request do
  let(:valid_attributes) {
    { project: { name: 'Test Project', description: 'Test Description', due_date: 1.week.from_now } }
  }

  let(:invalid_attributes) {
    { project: { name: nil, description: nil, due_date: nil } }
  }

  describe 'GET /api/v1/projects' do
    it 'returns a list of projects' do
      create(:project, valid_attributes[:project]) # Use FactoryBot
      get api_v1_projects_url # Named route
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe 'GET /api/v1/projects/:id' do
    it 'returns a single project' do
      project = create(:project, valid_attributes[:project]) # Use FactoryBot
      get api_v1_project_url(project) # Named route
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['name']).to eq('Test Project')
    end

    it 'returns a 404 if project is not found' do
      get api_v1_project_url(999) # Named route, pass ID directly
      expect(response).to have_http_status(404)
      expect(JSON.parse(response.body)['error']).to eq('Project not found')
    end
  end

  describe 'POST /api/v1/projects' do
    context 'with valid parameters' do
      it 'creates a new project' do
        expect {
          post api_v1_projects_url, params: valid_attributes # Named route
        }.to change(Project, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'renders a JSON response with the new project' do
        post api_v1_projects_url, params: valid_attributes # Named route
        expect(JSON.parse(response.body)['name']).to eq('Test Project')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new project' do
        expect {
          post api_v1_projects_url, params: invalid_attributes # Named route
        }.to change(Project, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders a JSON response with errors for the new project' do
        post api_v1_projects_url, params: invalid_attributes # Named route
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'PATCH /api/v1/projects/:id' do
    let(:new_attributes) { { project: { name: 'Updated Project' } } }

    context 'with valid parameters' do
      it 'updates the requested project' do
        project = create(:project, valid_attributes[:project]) # Use FactoryBot
        patch api_v1_project_url(project), params: new_attributes # Named route
        project.reload
        expect(project.name).to eq('Updated Project')
        expect(response).to have_http_status(200)
      end

      it 'renders a JSON response with the project' do
        project = create(:project, valid_attributes[:project]) # Use FactoryBot
        patch api_v1_project_url(project), params: new_attributes # Named route
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['name']).to eq('Updated Project')
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the project' do
        project = create(:project, valid_attributes[:project]) # Use FactoryBot
        patch api_v1_project_url(project), params: invalid_attributes # Named route
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    it 'destroys the requested project' do
      project = create(:project, valid_attributes[:project]) # Use FactoryBot
      expect {
        delete api_v1_project_url(project) # Named route
      }.to change(Project, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 422 when destroy fails' do
      project = create(:project, valid_attributes[:project]) # Use FactoryBot
      allow_any_instance_of(Project).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new("Destroy Failed"))

      delete api_v1_project_url(project) # Named route
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq("Destroy Failed")
    end
  end
end