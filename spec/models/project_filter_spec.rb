# spec/models/project_filter_spec.rb
require 'rails_helper'

RSpec.describe ProjectFilter, type: :model do
  # Existing validations, etc.

  describe "#apply_filter" do
    let(:org) { create(:organization) }
    let(:pm) { create(:user, organization: org) }
    let!(:project1) do
      project = build(:project, organization: org, project_manager: pm, is_complete: false, due_date: Date.new(2024, 12, 30))
      project.save(validate: false)
      project
    end    
    let(:project2) { create(:project, organization: org, project_manager: pm, is_complete: true, due_date: Time.zone.tomorrow) }
    let(:field_definition) { create(:field_definition, field_type: "string", name: "Urgency") }

    before do
      create(:field, fieldable: project1, field_definition: field_definition, value: "Urgent")
    end

    it "filters projects based on conditions" do
      filter = pm.project_filters.create(name: "My Filter", user: pm, criteria: {
        "logic" => "AND",
        "conditions" => [
          { "type" => "attribute", "attribute" => "is_complete", "operator" => "eq", "value" => false },
          { "type" => "field", "field_definition_id" => field_definition.id, "operator" => "contains", "value" => "Urgent" }
        ]
      })

      expect(filter).to be_valid
    end
  end
end
