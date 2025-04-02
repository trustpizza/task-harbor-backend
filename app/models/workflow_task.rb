class WorkflowTask < ApplicationRecord
  belongs_to :workflow
  belongs_to :task
end
