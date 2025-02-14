# spec/requests/field_values_spec.rb
require 'rails_helper'

RSpec.describe "FieldValues API", type: :request do
  let!(:field_definition) { FieldDefinition.create(name: "Test Field", field_type: "string") }

  describe "GET /projects/:project_id/fields/:field_id/field_values" do
    it "returns all field values for a field" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      debugger
      field = project.fields.create!(field_definition: field_definition)
      FieldValue.create(field: field, value: "Value 1")
      FieldValue.create(field: field, value: "Value 2")

      get "/projects/#{project.id}/fields/#{field.id}/field_values"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(2)
    end

    it "returns an empty array if no field values exist" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)

      get "/projects/#{project.id}/fields/#{field.id}/field_values"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to eq([])
    end

    it "returns a 404 if the field does not exist" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)

      get "/projects/#{project.id}/fields/#{field.id + 1}/field_values" # Invalid field ID
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /projects/:project_id/fields/:field_id/field_values" do
    let(:valid_attributes) { { value: "New Value" } }
    let(:invalid_attributes) { { value: nil } }

    it "creates a new field value" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)

      post "/projects/#{project.id}/fields/#{field.id}/field_values", params: valid_attributes
      expect(response).to have_http_status(201)
      expect(FieldValue.count).to eq(1)
      expect(JSON.parse(response.body)["value"]).to eq("New Value")
    end

    it "returns an error if the field value is invalid" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)

      post "/projects/#{project.id}/fields/#{field.id}/field_values", params: invalid_attributes
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end

    it "returns a 404 if the field does not exist" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)

      post "/projects/#{project.id}/fields/#{field.id + 1}/field_values", params: valid_attributes
      expect(response).to have_http_status(404)
    end
  end

  describe "GET /projects/:project_id/fields/:field_id/field_values/:id" do
    it "returns the field value" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)
      field_value = FieldValue.create(field: field, value: "Existing Value")

      get "/projects/#{project.id}/fields/#{field.id}/field_values/#{field_value.id}"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["value"]).to eq("Existing Value")
    end

    it "returns a 404 if the field value does not exist" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)
      field_value = FieldValue.create(field: field, value: "Existing Value")

      get "/projects/#{project.id}/fields/#{field.id}/field_values/#{field_value.id + 1}"
      expect(response).to have_http_status(404)
    end
  end

  describe "PUT /projects/:project_id/fields/:field_id/field_values/:id" do
    let(:updated_attributes) { { value: "Updated Value" } }
    let(:invalid_attributes) { { value: nil } }

    it "updates the field value" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)
      field_value = FieldValue.create(field: field, value: "Existing Value")

      put "/projects/#{project.id}/fields/#{field.id}/field_values/#{field_value.id}", params: updated_attributes
      expect(response).to have_http_status(200)
      expect(FieldValue.find(field_value.id).value).to eq("Updated Value")
    end

    it "returns an error if the update is invalid" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)
      field_value = FieldValue.create(field: field, value: "Existing Value")

      put "/projects/#{project.id}/fields/#{field.id}/field_values/#{field_value.id}", params: invalid_attributes
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end

    it "returns a 404 if the field value does not exist" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)
      field_value = FieldValue.create(field: field, value: "Existing Value")

      put "/projects/#{project.id}/fields/#{field.id}/field_values/#{field_value.id + 1}", params: updated_attributes
      expect(response).to have_http_status(404)
    end
  end

  describe "DELETE /projects/:project_id/fields/:field_id/field_values/:id" do
    it "deletes the field value" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)
      field_value = FieldValue.create(field: field, value: "To Delete")

      delete "/projects/#{project.id}/fields/#{field.id}/field_values/#{field_value.id}"
      expect(response).to have_http_status(204)
      expect(FieldValue.exists?(field_value.id)).to be false
    end

    it "returns a 404 if the field value does not exist" do
      project = Project.create(name: "Test Project", due_date: Date.tomorrow)
      field = project.fields.create!(field_definition: field_definition)
      field_value = FieldValue.create(field: field, value: "To Delete")

      delete "/projects/#{project.id}/fields/#{field.id}/field_values/#{field_value.id + 1}"
      expect(response).to have_http_status(404)
    end
  end
end