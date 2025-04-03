class Field < ApplicationRecord
  belongs_to :fieldable, polymorphic: true
  belongs_to :field_definition
  has_many :field_values, dependent: :destroy
end