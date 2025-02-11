FactoryBot.define do
  factory :project_field_value do
    project # Associate with a project
    project_field_definition # Associate with a field definition

    # Dynamically generate value based on field type
    value do
      field_type = project_field_definition.field_type
      case field_type
      when "integer"
        Faker::Number.between(from: 1, to: 100)
      when "date"
        Faker::Date.between(from: Date.today, to: 1.year.from_now)
      when "boolean"
        [true, false].sample
      when "dropdown"
        # Parse options and select one randomly. Handle if no options.
        begin
          options = JSON.parse(project_field_definition.options)
          options.sample if options.present?
        rescue JSON::ParserError
          nil
        end
      else # string or text
        Faker::Lorem.sentence
      end
    end
  end
end