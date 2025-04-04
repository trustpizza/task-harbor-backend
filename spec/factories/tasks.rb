FactoryBot.define do
  factory :task do
    name { "MyString" }
    description { "MyText" }
    due_date { Time.zone.tomorrow }
    association :taskable, factory: :project # Default to a project as the taskable
  end
end