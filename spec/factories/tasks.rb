FactoryBot.define do
  factory :task do
    name { "MyString" }
    description { "MyText" }
    due_date { "2025-02-19 13:39:06" }
    status { "MyString" }
    project { nil }
  end
end
