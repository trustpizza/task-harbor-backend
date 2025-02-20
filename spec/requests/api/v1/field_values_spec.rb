require 'rails_helper'

RSpec.describe Api::V1::FieldValuesController, type: :request do
  let!(:project) { create(:project) }
  let!(:field_definition) { create(:field_definition, required: true, field_type: "string") }
  let!(:field) { create(:field, fieldable: project, field_definition: field_definition) }
  let!(:field_value) { create(:field_value, field: field) }

  describe 'GET /api/v1/projects/:project_id/field_values' do
    it 'returns a list of field values for a project' do
      get "/api/v1/projects/#{project.id}/field_values"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(1)
    end

    it 'returns an empty array when no field values are found' do
      project2 = create(:project)
      get "/api/v1/projects/#{project2.id}/field_values"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(0)
    end

    it 'returns a 404 if project is not found' do
      get "/api/v1/projects/999/field_values"
      expect(response).to have_http_status(404)
    end
  end

  describe 'GET /api/v1/projects/:project_id/fields/:field_id/field_values/:id' do
    it 'returns a single field value' do
      get "/api/v1/projects/#{project.id}/field_values/#{field_value.id}"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['id']).to eq(field_value.id)
    end

    it 'returns a 404 if field value is not found' do
      get "/api/v1/projects/#{project.id}/field_values/999"
      expect(response).to have_http_status(404)
    end
  end

  describe 'POST /api/v1/projects/:project_id/field_values' do
    context 'with valid parameters' do
      it 'creates a field value' do
        valid_params = {
          value: 'test1',
          field_id: field.id
        }
        expect {
          post "/api/v1/projects/#{project.id}/field_values", params: valid_params
        }.to change(project.field_values, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity if a field value fails validation' do
        invalid_params = {
          value: nil,
          field_id: field.id
        }
        post "/api/v1/projects/#{project.id}/field_values", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns not found if a field does not exist' do
        invalid_params = {
          value: 'test',
          field_id: 999
        }
        post "/api/v1/projects/#{project.id}/field_values", params: invalid_params
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/v1/projects/:project_id/field_values/:id' do
    context 'with valid parameters' do
      it 'updates the requested field value' do
        patch "/api/v1/projects/#{project.id}/field_values/#{field_value.id}", params: { value: 'updated value', field_id: field.id }
        field_value.reload
        expect(field_value.value).to eq('updated value')
        expect(response).to have_http_status(200)
      end

      it 'renders a JSON response with the field value' do
         patch "/api/v1/projects/#{project.id}/field_values/#{field_value.id}", params: { value: 'updated value', field_id: field.id }
        expect(JSON.parse(response.body)['value']).to eq('updated value')
      end

      it 'returns 422 if the field value does not belong to the field' do
        other_field = create(:field, fieldable: project, field_definition: field_definition)
        patch "/api/v1/projects/#{project.id}/field_values/#{field_value.id}", params: { value: 'updated value', field_id: other_field.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns 404 if field is not found' do
        patch "/api/v1/projects/#{project.id}/field_values/#{field_value.id}", params: { value: 'updated value', field_id: 999 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors' do
        patch "/api/v1/projects/#{project.id}/field_values/#{field_value.id}", params: { value: nil, field_id: field.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/projects/:project_id/field_values/:id' do
    it 'destroys the requested field value' do
      expect {
        delete "/api/v1/projects/#{project.id}/field_values/#{field_value.id}"
      }.to change(project.field_values, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns unprocessable entity if destroy fails' do
      allow_any_instance_of(FieldValue).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new("Failed to destroy"))

      delete "/api/v1/projects/#{project.id}/field_values/#{field_value.id}"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end