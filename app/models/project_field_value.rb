class ProjectFieldValue < ApplicationRecord
  belongs_to :project_field_definition
  belongs_to :project

  validate :value_format

  def value_format
    return unless project_field_definition&.field_type

    field_type = project_field_definition.field_type
    value_to_validate = self.value.to_s.strip # Ensure it's a string and remove extra spaces
    required = project_field_definition.required?

    if required && value_to_validate.blank?
      errors.add(:value, "is required for this field")
      return
    end

    return if value_to_validate.blank? # Allow non-required fields to be blank

    case field_type
    when "integer"
      errors.add(:value, "must be an integer") unless value_to_validate.match?(/\A-?\d+\z/)
    when "date"
      errors.add(:value, "must be a valid date") unless Date.parse(value_to_validate) rescue false
    when "boolean"
      unless value_to_validate.downcase.in?(["true", "false"])
        errors.add(:value, "must be true or false")
      end
    when "string"
      # if project_field_definition.min_length && value_to_validate.length < project_field_definition.min_length
      #   errors.add(:value, "must be at least #{project_field_definition.min_length} characters")
      # end

      # if project_field_definition.max_length && value_to_validate.length > project_field_definition.max_length
      #   errors.add(:value, "cannot exceed #{project_field_definition.max_length} characters")
      # end

      # if project_field_definition.format && !(value_to_validate =~ Regexp.new(project_field_definition.format))
      #   errors.add(:value, "is not in the correct format")
      # end
    else
      errors.add(:field_type, "is not supported")
    end
  end
end