class FieldValue < ApplicationRecord
  belongs_to :field
  delegate :field_definition, to: :field

  validate :value_format

  # Define the attribute type casting based on field_definition.field_type
  def value
    val = read_attribute(:value) # Get the raw value from the database

    return nil unless field_definition&.field_type && val.present?

    case field_definition.field_type
    when "integer"
      val.to_i if val.present? # Cast to integer
    when "date"
      Date.parse(val) rescue nil if val.present? # Cast to date
    when "boolean"
      val.downcase == 'true' if val.present? # Cast to boolean (true/false)
    # when "string"  No casting needed for strings, handled by default
    else
      val # Return raw value for unsupported types
    end

  end

  def value=(val)
    super(val)
  end


  def value_format
    return unless field_definition&.field_type

    field_type = field_definition.field_type
    value_to_validate = self.value.to_s.strip # Ensure it's a string and remove extra spaces
    required = field_definition.required?

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
      unless value_to_validate.to_s.downcase.in?(["true", "false"])
        errors.add(:value, "must be true or false.  Instead got #{value_to_validate.to_s}")
      end
    when "string"
    else
      errors.add(:field_type, "is not supported: #{field_type}")
    end
  end
end