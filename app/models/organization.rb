class Organization < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  has_many :users
  has_many :projects

  accepts_nested_attributes_for :address
end
