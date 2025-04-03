class Workflow < ApplicationRecord
  belongs_to :project
  has_many :task_workflows, dependent: :destroy
  has_many :tasks, through: :task_workflows

  # Validations
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :description, presence: true, length: { minimum: 1, maximum: 500 }

  def should_trigger?(conditions)
    # Implement logic to evaluate conditions
    # Example: conditions[:status] == "ready"
  end
end