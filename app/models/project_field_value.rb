class ProjectFieldValue < ApplicationRecord
  belongs_to :project
  belongs_to :project_field_definition

  validate :value_format

  def value_format
    return unless project_field_definition&.field_type
  
    field_type = project_field_definition.field_type
    value_to_validate = self.value
  
    # ***THIS IS THE KEY CHANGE***
    current_field_definition = ProjectFieldDefinition.find(self.project_field_definition_id)
    puts(current_field_definition.required)
  
    case field_type
    when "integer", "date"
      if current_field_definition.required? && value_to_validate.nil? # Use current_field_definition
        errors.add(:value, "cannot be nil for this field type (required)")
      elsif value_to_validate.present?
        begin
          Integer(value_to_validate) if field_type == "integer"
          Date.parse(value_to_validate) if field_type == "date"
        rescue ArgumentError
          errors.add(:value, "must be a valid #{field_type}")
        end
      end
    when "boolean"
      unless value_to_validate.nil? || value_to_validate.downcase == "true" || value_to_validate.downcase == "false"
        errors.add(:value, "must be a boolean (true/false)")
      end
    end
  end
end