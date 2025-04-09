# app/models/project_filter.rb
class ProjectFilter < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :criteria, presence: true

  # You might add validation for the structure of the criteria JSON here
  # validate :validate_criteria_structure

  # Example structure for criteria JSON:
  # {
  #   "logic": "AND", // or "OR"
  #   "conditions": [
  #     { "type": "attribute", "attribute": "is_complete", "operator": "eq", "value": false },
  #     { "type": "attribute", "attribute": "due_date", "operator": "lt", "value": "2024-12-31" },
  #     { "type": "field", "field_definition_id": 15, "operator": "contains", "value": "Urgent" },
  #     { "type": "field", "field_definition_name": "Client Name", "operator": "eq", "value": "Acme Corp" }
  #   ]
  # }
  # Note: Using field_definition_id is more robust than name.

  private

  # def validate_criteria_structure
  #   # Add logic to ensure criteria JSON has the expected keys/values/types
  # end
end
