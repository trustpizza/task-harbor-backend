class Project < ApplicationRecord
  # Associations
  has_many :fields, as: :fieldable, dependent: :destroy
  has_many :field_definitions, through: :fields
  has_many :field_values, through: :fields
  has_many :tasks, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 5000 }, allow_blank: true # Allow blank descriptions
  validates :due_date, comparison: { greater_than_or_equal_to: -> { Time.zone.today } }, presence: true
  
  # Scopes
  scope :upcoming, -> { where("due_date >= ?", Time.zone.today) }
  scope :overdue, -> { where("due_date < ?", Time.zone.today) }

  def set_creation_date
    self.creation_date = Time.zone.today
  end
end
