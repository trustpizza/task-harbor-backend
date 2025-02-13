class Field < ApplicationRecord
  belongs_to :project
  belongs_to :field_definition
  has_many :field_values
end
