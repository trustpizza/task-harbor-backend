class Project < ApplicationRecord
  has_many :project_field_definitions, dependent: :destroy
  has_many :project_field_values, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 5000 }, presence: true
  validates :due_date, comparison: { greater_than_or_equal_to: -> { Date.today } }, presence: true

  scope :upcoming, -> { where("due_date >= ?", Date.today) }

  scope :overdue, -> { where("due_date < ?", Date.today) }
end
