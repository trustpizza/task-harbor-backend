FactoryBot.define do
  factory :workflow do
    project { association :project }
    name { "MyString" }
    description { "MyText" }
  end
end
