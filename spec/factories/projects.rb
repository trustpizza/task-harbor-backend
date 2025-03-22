FactoryBot.define do
  factory :project do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    due_date { Time.zone.tomorrow }
    organization { association(:organization) }
    project_manager { association(:user) }
  end
end