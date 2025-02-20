require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:project) { create(:project) }
  describe 'validations' do
    it 'is valid with valid attributes' do
      task = build(:task, project: project, project: project)
      expect(task).to be_valid
    end

    it 'is not valid without a name' do
      task = build(:task, project: project, name: nil)
      expect(task).to_not be_valid
      expect(task.errors[:name]).to include("can't be blank")
    end

    it "it is valid without a description" do
      task = build(:task, project: project, description: nil)
      expect(task).to be_valid
    end

    it 'is not valid without a due_date' do
      task = build(:task, project: project, due_date: nil)
      expect(task).to_not be_valid
      expect(task.errors[:due_date]).to include("can't be blank")
    end

    it 'is not valid with a due_date in the past' do
      task = build(:task, project: project, due_date: Time.zone.today - 2.days)
      expect(task).to_not be_valid
      expect(task.errors[:due_date]).to include("must be greater than or equal to #{Time.zone.today}")
    end
  end

  describe 'associations' do
    it 'has many fields' do
      task = create(:task, project: project)
      field_def = create(:field_definition)
      create(:field, fieldable: task, field_definition: field_def) # Create a Field, not FieldDefinition directly
      expect(task.fields.count).to eq(1)
    end

    it 'has many field_definitions through fields' do
      task = create(:task, project: project)
      field_def = create(:field_definition)
      field = create(:field, fieldable: task, field_definition: field_def)
      expect(task.field_definitions).to include(field.field_definition)
    end

    it 'has many field_values through fields' do
      task = create(:task, project: project)
      field_def = create(:field_definition)
      field = create(:field, fieldable: task, field_definition: field_def)
      create(:field_value, field: field)
      expect(task.field_values.count).to eq(1)
    end
  end

  describe 'scopes' do
    describe 'upcoming' do
      it 'returns tasks with due dates in the future' do
        create(:task, project: project, due_date: Date.tomorrow)
        overdue_task = build(:task, project: project) # Use build to create in memory
        overdue_task.assign_attributes(due_date: Date.yesterday) # Overwrite due_date
        overdue_task.save(validate: false)
        expect(Project.upcoming.count).to eq(1)
      end
    end

    describe 'overdue' do
      it 'returns tasks with due dates in the past' do
        create(:task, project: project, due_date: Date.tomorrow)
        create(:task, project: project, due_date: Time.zone.today)
        overdue_task = build(:task, project: project) # Use build to create in memory
        overdue_task.assign_attributes(due_date: Date.yesterday) # Overwrite due_date
        overdue_task.save(validate: false)
        expect(Task.overdue.count).to eq(1)
        expect(Task.overdue).to include(overdue_task)
      end
    end
  end
end
