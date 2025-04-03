class Workflow < ApplicationRecord
  belongs_to :organization
  has_and_belongs_to_many :projects # Added many-to-many relationship

  has_many :tasks, as: :taskable, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :description, presence: true, length: { minimum: 1, maximum: 500 }
end