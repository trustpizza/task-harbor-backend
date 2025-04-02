class TaskWorkflow < ApplicationRecord
  belongs_to :task
  belongs_to :workflow
end