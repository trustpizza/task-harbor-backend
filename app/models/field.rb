class Field < ApplicationRecord
  belongs_to :fieldable, polymorphic: true
  belongs_to :field_definition
  has_one :field_value, dependent: :destroy
end