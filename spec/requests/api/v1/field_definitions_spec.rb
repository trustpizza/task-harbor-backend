require 'rails_helper'

RSpec.describe Api::V1::FieldDefinitionsController, type: :request do
  describe 'GET /api/v1/field_definitions' do
    let!(:field_definition1) { create(:field_definition) }
    let!(:field_definition2) { create(:field_definition) }

    it 'returns a list of field definitions' do
      get api_v1_field_definitions_url # Use the named route
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(2)
    end

    it 'returns an empty array when no field definitions are found' do
      FieldDefinition.destroy_all
      get api_v1_field_definitions_url # Use the named route
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(0)
    end
  end

  describe 'GET /api/v1/field_definitions/:id' do
    let!(:field_definition) { create(:field_definition) }

    it 'returns a single field definition' do
      get api_v1_field_definition_url(field_definition) # Use the named route
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['id']).to eq(field_definition.id)
    end

    it 'returns a 404 if field definition is not found' do
      get api_v1_field_definition_url(999) # Pass the ID directly
      expect(response).to have_http_status(404)
    end
  end

  describe 'POST /api/v1/field_definitions' do
    context 'with valid parameters' do
      it 'creates a field definition' do
        valid_params = {
          name: 'Test Field',
          field_type: 'string',
          options: nil,
          required: false
        }
        expect {
          post api_v1_field_definitions_url, params: { field_definition: valid_params } # Use named route
        }.to change(FieldDefinition, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity if a field definition fails validation' do
        invalid_params = {
          name: nil,
          field_type: 'invalid'
        }
        post api_v1_field_definitions_url, params: { field_definition: invalid_params } # Use named route
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /api/v1/field_definitions/:id' do
    let!(:field_definition) { create(:field_definition) }

    context 'with valid parameters' do
      it 'updates the requested field definition' do
        patch api_v1_field_definition_url(field_definition), params: { field_definition: { name: 'Updated Field' } } # Use named route
        field_definition.reload
        expect(field_definition.name).to eq('Updated Field')
        expect(response).to have_http_status(200)
      end

      it 'renders a JSON response with the field definition' do
        patch api_v1_field_definition_url(field_definition), params: { field_definition: { name: 'Updated Field' } } # Use named route
        expect(JSON.parse(response.body)['name']).to eq('Updated Field')
      end
    end

    context 'with invalid parameters' do
       it 'renders a JSON response with errors' do
        patch api_v1_field_definition_url(field_definition), params: { field_definition: { name: nil } } # Use named route
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/field_definitions/:id' do
    let!(:field_definition) { create(:field_definition) }

    it 'destroys the requested field definition' do
      expect {
        delete api_v1_field_definition_url(field_definition) # Use named route
      }.to change(FieldDefinition, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns unprocessable entity if destroy fails' do
      allow_any_instance_of(FieldDefinition).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new("Failed to destroy"))

      delete api_v1_field_definition_url(field_definition) # Use named route
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end