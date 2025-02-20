FactoryBot.define do
  factory :field do
    field_definition
    association :fieldable, factory: :project
  end
end
