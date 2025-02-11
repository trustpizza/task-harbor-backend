class Project < ApplicationRecord
  has_many :project_field_definitions, dependent: :destroy
  has_many :project_field_values, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 5000 }
  validates :due_date, comparison: { greater_than_or_equal_to: Date.today }, allow_blank: true
end