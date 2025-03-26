require 'rails_helper'

RSpec.describe Api::V1::FieldsController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization) }
  let!(:project) { create(:project, organization: organization) }
  let!(:field_definition) { create(:field_definition, field_type: "string", required: false) }

  let(:valid_attributes) { { field: { field_definition_id: field_definition.id.to_s } } }
  let(:invalid_attributes) { { field: { field_definition_id: nil } } }

  describe 'GET /api/v1/projects/:project_id/fields' do
    it 'returns a list of fields for a project' do
      create(:field, fieldable: project, field_definition: field_definition)
      get api_v1_project_fields_url(project), headers: auth_header(user)
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].size).to eq(1)
    end
  end

  describe 'GET /api/v1/projects/:project_id/fields/:id' do
    it 'returns a single field' do
      field = create(:field, fieldable: project, field_definition: field_definition)
      get api_v1_project_field_url(project, field), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end

    it 'returns a 404 if field is not found' do
      get api_v1_project_field_url(project, 999), headers: auth_header(user)
      expect(response).to have_http_status(404)
      expect(JSON.parse(response.body)['error']).to eq('Not Found')
    end
  end

  describe 'POST /api/v1/projects/:project_id/fields' do
    context 'with valid parameters' do
      it 'creates a new field' do
        expect {
          post api_v1_project_fields_url(project), params: valid_attributes.to_json, headers: auth_header(user)
        }.to change(project.fields, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new field' do
        expect {
          post api_v1_project_fields_url(project), params: invalid_attributes.to_json, headers: auth_header(user)
        }.to change(project.fields, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders a JSON response with errors for the new field' do
        post api_v1_project_fields_url(project), params: invalid_attributes.to_json, headers: auth_header(user)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'PATCH /api/v1/projects/:project_id/fields/:id' do
    let(:new_field_definition) { create(:field_definition) }
    let(:new_attributes) { { field: { field_definition_id: new_field_definition.id.to_s } } }

    context 'with valid parameters' do
      it 'updates the requested field' do
        field = create(:field, fieldable: project, field_definition: field_definition)
        patch api_v1_project_field_url(project, field), params: new_attributes.to_json, headers: auth_header(user)
        field.reload
        expect(response).to have_http_status(200)
      end

      it 'renders a JSON response with the field' do
        field = create(:field, fieldable: project, field_definition: field_definition)
        patch api_v1_project_field_url(project, field), params: new_attributes.to_json, headers: auth_header(user)
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the field' do
        field = create(:field, fieldable: project, field_definition: field_definition)
        patch api_v1_project_field_url(project, field), params: invalid_attributes.to_json, headers: auth_header(user)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/projects/:project_id/fields/:id' do
    it 'destroys the requested field' do
      field = create(:field, fieldable: project, field_definition: field_definition)
      expect {
        delete api_v1_project_field_url(project, field), headers: auth_header(user)
      }.to change(project.fields, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end