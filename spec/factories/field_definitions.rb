FactoryBot.define do
  factory :field_definition do
    name { Faker::Lorem.word }
    field_type { %w[string integer date boolean text].sample }
    project { association(:project) }
    required { false } # Default value

    trait :required do
      required { true }
    end

    trait :optional do
      required { false } # While redundant, it's explicit
    end

    # More robust options handling:
    options do
      case field_type
      when "dropdown"
        Faker::Lorem.words(number: 3..5).to_json
      when "integer"
        { min: Faker::Number.between(from: 0, to: 10), max: Faker::Number.between(from: 11, to: 100) }.to_json
      else
        nil # Or '[]' for consistency if you want an empty JSON array for other types
      end
    end
  end
end