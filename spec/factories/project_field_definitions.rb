FactoryBot.define do
  factory:project_field_definition do
    name { Faker::Lorem.word } # Or a more descriptive name if needed
    field_type { %w[string integer date boolean dropdown text].sample } # Randomly select a valid field type
    project # Associate with a project
    options do
      if field_type == "dropdown"
        Faker::Lorem.words(number: 3..5).to_json # Example dropdown options
      elsif field_type == "integer"
        { min: Faker::Number.between(from: 0, to: 10), max: Faker::Number.between(from: 11, to: 100) }.to_json
      else
        nil # No options for other field types in this example
      end
    end
  end
end