FactoryBot.define do
  factory :project_field_value do
    project # Associate with a project
    project_field_definition # Associate with a field definition

    # Dynamically generate value based on field type
    value do
      field_type = project_field_definition&.field_type || "unknown"
      case field_type
      when "integer"
        Faker::Number.between(from: 1, to: 100).to_s  # Convert to string
      when "date"
        Faker::Date.between(from: Date.today, to: 1.year.from_now).to_s # Convert to string (e.g., "2024-10-27")
      when "boolean"
        [true, false].sample.to_s # Convert to string ("true" or "false")
      when "dropdown"
        options = JSON.parse(project_field_definition.options) rescue []
        options.any? ? options.sample : "default_option" # No change needed here, as it's already a string
      else # string or text
        Faker::Lorem.sentence
      end
    end
    
  end
end