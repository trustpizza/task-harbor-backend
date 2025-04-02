FactoryBot.define do
  factory :workflow_task do
    workflow { nil }
    task { nil }
    position { 1 }
  end
end
