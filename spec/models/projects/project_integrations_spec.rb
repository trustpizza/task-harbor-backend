require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      project = build(:project)
      expect(project).to be_valid
    end

    it "is not valid without a name" do
      project = build(:project, name: nil)
      expect(project).to_not be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end

    it "is not valid without a description" do
      project = build(:project, description: nil)
      expect(project).to_not be_valid
      expect(project.errors[:description]).to include("can't be blank")
    end

    it "is not valid without a due_date" do
      project = build(:project, due_date: nil)
      expect(project).to_not be_valid
      expect(project.errors[:due_date]).to include("can't be blank")
    end

    it "is not valid with a due_date in the past" do
      project = build(:project, due_date: Time.zone.today - 2.days) # Use 2 days ago
      expect(project).to_not be_valid
      expect(project.errors[:due_date]).to include("must be greater than or equal to #{Time.zone.today}")
    end
  end

  describe "associations" do
    it "has many field_definitions" do
      project = create(:project)
      create(:field_definition, project: project)
      expect(project.field_definitions.count).to eq(1)
    end

    it "has many field_values" do
      project = create(:project)
      field_definition = create(:field_definition, project: project)
      create(:field_value, project: project, field_definition: field_definition)
      expect(project.field_values.count).to eq(1)
    end
  end

  describe "scopes" do
    describe "upcoming" do
      it "returns projects with due dates in the future" do
        create(:project, due_date: Date.tomorrow)
        build(:project, due_date: Date.yesterday)
        expect(Project.upcoming.count).to eq(1)
      end
    end
    describe "overdue" do
      it "returns projects with due dates in the past" do
        create(:project, due_date: Date.tomorrow)  # Should NOT be included
        create(:project, due_date: Time.zone.today)     # Should NOT be included
        # Bypass validation to create an overdue project
        overdue_project = build(:project, due_date: Date.yesterday)
        overdue_project.save(validate: false) 
  
        expect(Project.overdue.count).to eq(1)
        expect(Project.overdue).to include(overdue_project)
      end
    end
  end
  
end
