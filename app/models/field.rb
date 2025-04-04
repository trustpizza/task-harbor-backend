class Field < ApplicationRecord
  belongs_to :fieldable, polymorphic: true
  belongs_to :field_definition
  
  validate :value_format

  def value
    val = read_attribute(:value)

    return nil unless field_definition&.field_type && val.present?

    case field_definition.field_type
    when "integer"
      val.to_i if val.present?
    when "date"
      Date.parse(val) rescue nil if val.present?
    when "boolean"
      val.downcase == 'true' || val.downcase == 't' if val.present?
    else  # String and unsupported types
      val
    end
  end

  def value=(val)
    super(val)
  end

  def value_format
    return unless field_definition&.field_type

    field_type = field_definition.field_type
    raw_value = read_attribute(:value).to_s.strip # Get the raw value!
    required = field_definition.required?

    if required && raw_value.blank?
      errors.add(:value, "is required for this field")
      return
    end

    return if raw_value.blank? # Allow non-required fields to be blank

    case field_type
    when "integer"
      errors.add(:value, "must be an integer") unless raw_value.match?(/\A-?\d+\z/)
    when "date"
      begin
        Date.parse(raw_value) # Try parsing
      rescue ArgumentError # Catch invalid date exceptions
        errors.add(:value, "must be a valid date")
      end  
    when "boolean"
      raw_value = read_attribute(:value) # Get the raw value
      unless raw_value.to_s.downcase.in?(["true", "false"])
        errors.add(:value, "must be true or false. Instead got #{raw_value}") # Use raw_value
      end
    when "string" # No validation needed for strings, but include for completeness in the case statement
    else
      errors.add(:field_type, "is not supported: #{field_type}")
    end
  end
end