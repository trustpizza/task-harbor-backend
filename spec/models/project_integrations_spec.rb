require 'rails_helper'
require 'debug'

RSpec.describe Project, type: :model do
  let(:org) { create(:organization) }
  let(:pm) { create(:user, organization: org) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      project = build(:project) # Factory will create with org and project_manager
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

    it 'is not valid without an organization' do
      project = build(:project, organization: nil)
      expect(project).to_not be_valid
      expect(project.errors[:organization]).to include("must exist")
    end

    it 'is not valid without a project_manager' do
      project = build(:project, project_manager: nil)
      expect(project).to_not be_valid
      expect(project.errors[:project_manager]).to include("must exist")
    end
  end

  describe 'associations' do
    it 'belongs to an organization' do
      association = described_class.reflect_on_association(:organization)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to a project_manager (user)' do
      association = described_class.reflect_on_association(:project_manager)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'has many fields' do
      project = create(:project, organization: org, project_manager: pm)
      field_def = create(:field_definition, field_type: "string")
      create(:field, fieldable: project, field_definition: field_def, value: "Sample Value")
      expect(project.fields.count).to eq(1)
      expect(project.fields.first.value).to eq("Sample Value")
    end

    it 'has many field_definitions through fields' do
      project = create(:project, organization: org, project_manager: pm)
      field_def = create(:field_definition)
      field = create(:field, fieldable: project, field_definition: field_def)
      expect(project.field_definitions).to include(field.field_definition)
    end

  end

  describe 'scopes' do
    describe 'upcoming' do
      it 'returns projects with due dates in the future' do
        create(:project, organization: org, project_manager: pm, due_date: Time.zone.tomorrow)
        overdue_project = build(:project, organization: org, project_manager: pm)
        overdue_project.assign_attributes(due_date: Time.zone.yesterday)
        overdue_project.save(validate: false)
        expect(Project.upcoming.count).to eq(1)
      end
    end

    describe 'overdue' do
      it 'returns projects with due dates in the past' do
        create(:project, organization: org, project_manager: pm, due_date: Time.zone.tomorrow)
        create(:project, organization: org, project_manager: pm, due_date: Time.zone.today)
        overdue_project = build(:project, organization: org, project_manager: pm)
        overdue_project.assign_attributes(due_date: Time.zone.yesterday)
        overdue_project.save(validate: false)
        expect(Project.overdue.count).to eq(1)
        expect(Project.overdue).to include(overdue_project)
      end
    end
  end
end