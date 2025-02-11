class ProjectFieldValue < ApplicationRecord
  belongs_to :project
  belongs_to :project_field_definition

  # Validate value based on the field_type of the associated ProjectFieldDefinition
  validate :value_format

  def value_format
    return unless project_field_definition # Make sure the association exists

    field_type = project_field_definition.field_type
    value_to_validate = self.value # Get the value to be validated

    case field_type
    when "integer"
      begin
        Integer(value_to_validate) # Try converting to Integer
      rescue ArgumentError
        errors.add(:value, "must be an integer")
      end
    when "date"
      begin
        Date.parse(value_to_validate)  # Try converting to Date
      rescue ArgumentError
        errors.add(:value, "must be a valid date")
      end
    when "boolean"
        unless value_to_validate.downcase == "true" || value_to_validate.downcase == "false"
          errors.add(:value, "must be a boolean (true/false)")
        end
    # Add more type specific validations here as needed.
    end
  end
end