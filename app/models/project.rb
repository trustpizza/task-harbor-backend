class Project < ApplicationRecord
  has_many :project_field_definitions, dependent: :destroy
  has_many :project_field_values, through: :project_field_definitions

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 5000 }
  validates :due_date, comparison: { greater_than_or_equal_to: -> { Time.zone.today } }, presence: true

  scope :upcoming, -> { where("due_date >= ?", Time.zone.today) }
  scope :overdue, -> { where("due_date < ?", Time.zone.today) }
end
