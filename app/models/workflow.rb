class Workflow < ApplicationRecord
  belongs_to :project
  has_many :task_workflows, dependent: :destroy
  has_many :tasks, through: :task_workflows
end