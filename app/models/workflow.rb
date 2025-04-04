class Workflow < ApplicationRecord
  belongs_to :organization
  has_many :project_workflows, dependent: :destroy
  has_many :projects, through: :project_workflows

  has_many :tasks, as: :taskable, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :description, presence: true, length: { minimum: 1, maximum: 500 }
end