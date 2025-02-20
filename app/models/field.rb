class Field < ApplicationRecord
  belongs_to :field_definition
  belongs_to :fieldable, polymorphic: true
  has_many :field_values, dependent: :destroy
end