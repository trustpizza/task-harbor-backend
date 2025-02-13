FactoryBot.define do
  factory :field_value do
    association :field
    # Dynamically generate value based on field type, but allow nil
    value do
      field_type = field_definition&.field_type || "unknown"
      case field_type
      when "integer"
        Faker::Number.between(from: 1, to: 100).to_s
      when "date"
        Faker::Date.between(from: Time.zone.today, to: 1.year.from_now).to_s
      when "boolean"
        [true, false].sample.to_s
      when "dropdown"
        options = JSON.parse(field_definition.options) rescue []
        options.any? ? options.sample : "default_option"
      else # string or text
        Faker::Lorem.sentence
      end
    end

    # Add a trait to allow overriding the value with nil
    trait :nil_value do
      value { nil }
    end
  end
end