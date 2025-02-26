FactoryBot.define do
  factory :address do
    association :addressable, factory: :organization # Default to Organization, but can be overridden
    address_line_1 { Faker::Address.street_address }
    address_line_2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    country { "USA" }
    latitude { nil } # Geocoding will set this
    longitude { nil }
  end
end
