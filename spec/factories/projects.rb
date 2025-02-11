FactoryBot.define do
  factory :project do
    name { Faker::Name.name }
    description { Faker::Lorem.paragraph }
    due_date { Faker::Date.forward(days: 30) }
  end
end