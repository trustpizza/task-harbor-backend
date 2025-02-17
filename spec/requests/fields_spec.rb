require 'rails_helper'
require 'debug'


RSpec.describe Api::V1::FieldsController, type: :request do
  let(:project) { create(:project) } # Using FactoryBot for project creation
  let(:field_definition) { create(:field_definition) } # Using FactoryBot for field definition creation
  let(:valid_attributes) {
    { field: { field_definition_id: field_definition.id } }
  }
  let(:invalid_attributes) {
    { field: { field_definition_id: nil } }
  }

  describe 'GET /api/v1/projects/:project_id/fields' do
    it 'returns a list of fields for a project' do
      create(:field, project: project, field_definition: field_definition)
      get "/api/v1/projects/#{project.id}/fields"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe 'GET /api/v1/projects/:project_id/fields/:id' do
    it 'returns a single field' do
      field = create(:field, project: project, field_definition: field_definition)
      get "/api/v1/projects/#{project.id}/fields/#{field.id}"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['field_definition_id']).to eq(field_definition.id)
    end

    it 'returns a 404 if field is not found' do
      get "/api/v1/projects/#{project.id}/fields/999"
      expect(response).to have_http_status(404)
    end
  end

  describe 'POST /api/v1/projects/:project_id/fields' do
    context 'with valid parameters' do
      it 'creates a new field' do
        expect {
          post "/api/v1/projects/#{project.id}/fields", params: valid_attributes
        }.to change(project.fields, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'renders a JSON response with the new field' do
        post "/api/v1/projects/#{project.id}/fields", params: valid_attributes
        expect(JSON.parse(response.body)['field_definition_id']).to eq(field_definition.id)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new field' do
        expect {
          post "/api/v1/projects/#{project.id}/fields", params: invalid_attributes
        }.to change(project.fields, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders a JSON response with errors for the new field' do
        post "/api/v1/projects/#{project.id}/fields", params: invalid_attributes
        expect(JSON.parse(response.body)).to be_present
      end
    end
  end

  describe 'PATCH /api/v1/projects/:project_id/fields/:id' do
    let(:new_field_definition) { create(:field_definition) }
    let(:new_attributes) {
      { field: { field_definition_id: new_field_definition.id } }
    }

    context 'with valid parameters' do
      it 'updates the requested field' do
        field = create(:field, project: project, field_definition: field_definition)
        patch "/api/v1/projects/#{project.id}/fields/#{field.id}", params: new_attributes
        field.reload
        expect(field.field_definition_id).to eq(new_field_definition.id)
        expect(response).to have_http_status(200)
      end

      it 'renders a JSON response with the field' do
        field = create(:field, project: project, field_definition: field_definition)
        patch "/api/v1/projects/#{project.id}/fields/#{field.id}", params: new_attributes
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['field_definition_id']).to eq(new_field_definition.id)
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the field' do
        field = create(:field, project: project, field_definition: field_definition)
        patch "/api/v1/projects/#{project.id}/fields/#{field.id}", params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/projects/:project_id/fields/:id' do
    it 'destroys the requested field' do
      field = create(:field, project: project, field_definition: field_definition)
      expect {
        delete "/api/v1/projects/#{project.id}/fields/#{field.id}"
      }.to change(project.fields, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end