FactoryBot.define do
  factory :workflow do
    organization { association :organization } # Updated to reference organization
    name { "MyString" }
    description { "MyText" }
  end
end
