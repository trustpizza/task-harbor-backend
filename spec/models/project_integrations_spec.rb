require 'rails_helper'
require 'debug'

RSpec.describe Project, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      project = build(:project)
      expect(project).to be_valid
    end

    it 'is not valid without a name' do
      project = build(:project, name: nil)
      expect(project).to_not be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end

    it "it is valid without a description" do
      project = build(:project, description: nil)
      expect(project).to be_valid
    end

    it 'is not valid without a due_date' do
      project = build(:project, due_date: nil)
      expect(project).to_not be_valid
      expect(project.errors[:due_date]).to include("can't be blank")
    end

    it 'is not valid with a due_date in the past' do
      project = build(:project, due_date: Time.zone.today - 2.days)
      expect(project).to_not be_valid
      expect(project.errors[:due_date]).to include("must be greater than or equal to #{Time.zone.today}")
    end
  end

  describe 'associations' do
    it 'has many fields' do
      project = create(:project)
      field_def = create(:field_definition)
      create(:field, fieldable: project, field_definition: field_def) # Create a Field, not FieldDefinition directly
      expect(project.fields.count).to eq(1)
    end

    it 'has many field_definitions through fields' do
      project = create(:project)
      field_def = create(:field_definition)
      field = create(:field, fieldable: project, field_definition: field_def)
      expect(project.field_definitions).to include(field.field_definition)
    end

    it 'has many field_values through fields' do
      project = create(:project)
      field_def = create(:field_definition)
      field = create(:field, fieldable: project, field_definition: field_def)
      create(:field_value, field: field)
      expect(project.field_values.count).to eq(1)
    end
  end

  describe 'scopes' do
    describe 'upcoming' do
      it 'returns projects with due dates in the future' do
        create(:project, due_date: Time.zone.tomorrow)
        overdue_project = build(:project) # Use build to create in memory
        overdue_project.assign_attributes(due_date: Time.zone.yesterday) # Overwrite due_date
        overdue_project.save(validate: false)
        expect(Project.upcoming.count).to eq(1)
      end
    end

    describe 'overdue' do
      it 'returns projects with due dates in the past' do
        create(:project, due_date: Time.zone.tomorrow)
        create(:project, due_date: Time.zone.today)
        overdue_project = build(:project) # Use build to create in memory
        overdue_project.assign_attributes(due_date: Time.zone.yesterday) # Overwrite due_date
        overdue_project.save(validate: false)
        expect(Project.overdue.count).to eq(1)
        expect(Project.overdue).to include(overdue_project)
      end
    end
  end
end