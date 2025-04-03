require 'rails_helper'
require 'debug'

RSpec.describe Task, type: :model do
  let(:org) { create(:organization) }
  let(:pm) { create(:user, organization: org) }
  let(:project) { create(:project, project_manager: pm, organization: org) }
  let(:workflow) { create(:workflow, organization: org) }

  describe 'validations' do
    it 'is valid with valid attributes for a project' do
      task = build(:task, taskable: project)
      expect(task).to be_valid
    end

    it 'is valid with valid attributes for a workflow' do
      task = build(:task, taskable: workflow)
      expect(task).to be_valid
    end

    it 'is not valid without a name' do
      task = build(:task, taskable: project, name: nil)
      expect(task).to_not be_valid
      expect(task.errors[:name]).to include("can't be blank")
    end

    it 'is valid without a description' do
      task = build(:task, taskable: project, description: nil)
      expect(task).to be_valid
    end

    it 'is not valid without a due_date' do
      task = build(:task, taskable: project, due_date: nil)
      expect(task).to_not be_valid
      expect(task.errors[:due_date]).to include("can't be blank")
    end

    it 'is not valid with a due_date in the past' do
      task = build(:task, taskable: project, due_date: Time.zone.today - 2.days)
      expect(task).to_not be_valid
      expect(task.errors[:due_date]).to include("must be greater than or equal to #{Time.zone.today}")
    end

    it { should validate_presence_of(:taskable) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:due_date) }
  end

  describe 'associations' do
    it 'has many fields for a project' do
      task = create(:task, taskable: project)
      field_def = create(:field_definition)
      create(:field, fieldable: task, field_definition: field_def)
      expect(task.fields.count).to eq(1)
    end

    it 'has many fields for a workflow' do
      task = create(:task, taskable: workflow)
      field_def = create(:field_definition)
      create(:field, fieldable: task, field_definition: field_def)
      expect(task.fields.count).to eq(1)
    end

    it 'has many field_definitions through fields' do
      task = create(:task, taskable: project)
      field_def = create(:field_definition)
      field = create(:field, fieldable: task, field_definition: field_def)
      expect(task.field_definitions).to include(field.field_definition)
    end

    it 'has many field_values through fields' do
      task = create(:task, taskable: project)
      field_def = create(:field_definition)
      field = create(:field, fieldable: task, field_definition: field_def)
      create(:field_value, field: field)
      expect(task.field_values.count).to eq(1)
    end

    it { should have_many(:fields).dependent(:destroy) }
    it { should have_many(:field_definitions).through(:fields) }
    it { should have_many(:field_values).through(:fields) }
  end

  describe 'scopes' do
    describe 'upcoming' do
      it 'returns tasks with due dates in the future' do
        create(:task, taskable: project, due_date: Time.zone.tomorrow)
        expect(Task.upcoming.count).to eq(1)
      end
    end

    describe 'overdue' do
      it 'returns tasks with due dates in the past' do
        create(:task, taskable: project, due_date: Time.zone.tomorrow)
        create(:task, taskable: project, due_date: Time.zone.today)
        overdue_task = build(:task, taskable: project)
        overdue_task.assign_attributes(due_date: Time.zone.yesterday)
        overdue_task.save(validate: false)
        expect(Task.overdue.count).to eq(1)
        expect(Task.overdue).to include(overdue_task)
      end

      it 'returns overdue tasks for a workflow' do
        overdue_task = build(:task, taskable: workflow)
        overdue_task.assign_attributes(due_date: Time.zone.yesterday)
        overdue_task.save(validate: false)
        expect(Task.overdue.count).to eq(1)
        expect(Task.overdue).to include(overdue_task)
      end
    end
  end
end
