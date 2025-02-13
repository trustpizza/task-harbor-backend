FactoryBot.define do
  factory :field_definition do
    name { Faker::Lorem.word }
    field_type { %w[string integer date boolean].sample }
    required { false }

    trait :required do
      required { true }
    end

    trait :optional do
      required { false }
    end

    # More robust options handling:
    options do
      case field_type
      when "dropdown"
        # Ensure consistent JSON array even if Faker returns nil
        (Faker::Lorem.words(number: 3..5) || []).to_json # Handle potential nil from Faker
      when "integer"
        { min: Faker::Number.between(from: 0, to: 10), max: Faker::Number.between(from: 11, to: 100) }.to_json
      else
        '[]' # Consistent empty JSON array for other types.  Use 'null' if you treat nil differently
      end
    end

    after(:create) do |field_definition| # Ensure options are parsed for validation in the model
      field_definition.options = JSON.parse(field_definition.options) if field_definition.options.present? && field_definition.field_type == 'dropdown'
    rescue JSON::ParserError
      puts "Error parsing options for field_definition #{field_definition.id}"
      # Handle error, perhaps set to '[]' or raise.  For now, just print it.
    end
  end
end