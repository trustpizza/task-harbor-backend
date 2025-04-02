class Task < ApplicationRecord
  # Associations
  belongs_to :project
  has_many :fields, as: :fieldable, dependent: :destroy
  has_many :field_definitions, through: :fields
  has_many :field_values, through: :fields
  has_and_belongs_to_many :workflows
  # Validations
  validates :name, presence: true
  validates :description, length: { maximum: 5000 }, allow_blank: true
  validates :due_date, comparison: { greater_than_or_equal_to: -> { Time.zone.today } }, presence: true
  # Scopes
  scope :upcoming, -> { where("due_date >= ?", Time.zone.today) }
  scope :overdue, -> { where("due_date < ?", Time.zone.today) }
end
