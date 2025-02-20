FactoryBot.define do
  factory :task do
    name { "MyString" }
    description { "MyText" }
    due_date { Date.today }
    project { nil }
  end
end
