FactoryBot.define do
  factory :task do
    name { "MyString" }
    description { "MyText" }
    due_date { "2025-04-03" }
    association :taskable, factory: :project # Default to a project as the taskable
  end
end