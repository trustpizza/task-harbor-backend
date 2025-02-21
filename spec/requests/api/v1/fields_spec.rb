require 'rails_helper'

RSpec.describe Api::V1::FieldsController, type: :request do
  let(:project) { create(:project) }
  let(:field_definition) { create(:field_definition, field_type: "string", required: false) }
  let(:valid_attributes) { { field: { field_definition_id: field_definition.id } } }
  let(:invalid_attributes) { { field: { field_definition_id: nil } } }
  
  describe 'GET /api/v1/projects/:project_id/fields' do
    it 'returns a list of fields for a project' do
      create(:field, fieldable: project, field_definition: field_definition)
      get api_v1_project_fields_url(project) # Named route
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe 'GET /api/v1/projects/:project_id/fields/:id' do
    it 'returns a single field' do
      field = create(:field, fieldable: project, field_definition: field_definition)
      get api_v1_project_field_url(project, field) # Named route
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['field_definition_id']).to eq(field_definition.id)
    end

    it 'returns a 404 if field is not found' do
      get api_v1_project_field_url(project, 999) # Pass ID directly
      expect(response).to have_http_status(404)
    end
  end

  describe 'POST /api/v1/projects/:project_id/fields' do
    context 'with valid parameters' do
      it 'creates a new field' do
        expect {
          post api_v1_project_fields_url(project), params: valid_attributes # Named route
        }.to change(project.fields, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'renders a JSON response with the new field' do
        post api_v1_project_fields_url(project), params: valid_attributes # Named route
        expect(JSON.parse(response.body)['field_definition_id']).to eq(field_definition.id)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new field' do
        expect {
          post api_v1_project_fields_url(project), params: invalid_attributes # Named route
        }.to change(project.fields, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders a JSON response with errors for the new field' do
        post api_v1_project_fields_url(project), params: invalid_attributes # Named route
        expect(JSON.parse(response.body)).to be_present
      end
    end
  end

  describe 'PATCH /api/v1/projects/:project_id/fields/:id' do
    let(:new_field_definition) { create(:field_definition) }
    let(:new_attributes) { { field: { field_definition_id: new_field_definition.id } } }

    context 'with valid parameters' do
      it 'updates the requested field' do
        field = create(:field, fieldable: project, field_definition: field_definition)
        patch api_v1_project_field_url(project, field), params: new_attributes # Named route
        field.reload
        expect(field.field_definition_id).to eq(new_field_definition.id)
        expect(response).to have_http_status(200)
      end

      it 'renders a JSON response with the field' do
        field = create(:field, fieldable: project, field_definition: field_definition)
        patch api_v1_project_field_url(project, field), params: new_attributes # Named route
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['field_definition_id']).to eq(new_field_definition.id)
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the field' do
        field = create(:field, fieldable: project, field_definition: field_definition)
        patch api_v1_project_field_url(project, field), params: invalid_attributes # Named route
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/projects/:project_id/fields/:id' do
    it 'destroys the requested field' do
      field = create(:field, fieldable: project, field_definition: field_definition)
      expect {
        delete api_v1_project_field_url(project, field) # Named route
      }.to change(project.fields, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end