FactoryBot.define do
  factory :project do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    due_date { Time.zone.tomorrow }
    organization { association(:organization) }
    is_complete { false }
    project_manager { association(:user) }
  end
end