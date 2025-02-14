require 'rails_helper'

RSpec.describe Field, type: :model do
  describe 'associations' do
    it 'belongs to a field definition' do
      field_definition = create(:field_definition)
      field = create(:field, field_definition: field_definition)
      expect(field.field_definition).to eq(field_definition)
    end

    it 'has many field values and destroys them when field is destroyed' do
      field = create(:field)
      create(:field_value, field: field)
      create(:field_value, field: field)
      expect(field.field_values.count).to eq(2)
      field.destroy
      expect(FieldValue.count).to eq(0)
    end

    it 'belongs to a project' do
      project = create(:project)
      field = create(:field, project: project)
      expect(field.project).to eq(project)
    end

  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      field = build(:field)
      expect(field).to be_valid
    end

    it 'is not valid without a field definition' do
      field = build(:field, field_definition: nil)
      expect(field).to_not be_valid
      expect(field.errors[:field_definition]).to include("must exist")
    end

    it 'is not valid without a project' do
      field = build(:field, project: nil)
      expect(field).to_not be_valid
      expect(field.errors[:project]).to include("must exist")
    end
  end
end