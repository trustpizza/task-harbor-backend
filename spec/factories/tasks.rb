FactoryBot.define do
  factory :task do
    name { "MyString" }
    description { "MyText" }
    due_date { Time.zone.today }
    project { nil }
  end
end
