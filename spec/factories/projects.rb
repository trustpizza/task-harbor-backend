FactoryBot.define do
  factory :project do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    due_date { Time.zone.tomorrow }
    organization { association :organization } # Assuming you have an organization factory
    project_manager { association :user } # Assuming you have a user factory
  end
end