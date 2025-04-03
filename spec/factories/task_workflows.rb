FactoryBot.define do
  factory :task_workflow do
    task { association :task }
    workflow { association :workflow }
  end
end
