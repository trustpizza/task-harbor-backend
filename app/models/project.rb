class Project < ApplicationRecord
  has_many :fields, dependent: :destroy
  has_many :field_definitions, through: :fields
  has_many :field_values, through: :fields

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 5000 }, allow_blank: true # Allow blank descriptions
  
  validates :due_date, comparison: { greater_than_or_equal_to: -> { Time.zone.today } }, presence: true

  scope :upcoming, -> { where("due_date >= ?", Time.zone.today) }
  scope :overdue, -> { where("due_date < ?", Time.zone.today) }
end
