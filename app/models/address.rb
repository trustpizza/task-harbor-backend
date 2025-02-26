class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  geocoded_by :geocoded_address

  validates :address_line_1, :city, :state, :zip, :country, presence: true
  
  after_validation :geocode
  reverse_geocoded_by :latitude, :longitude
  
  def geocoded_address
    [address_line_1, city, state, zip, country].compact.join(', ')
  end
  
  def full_address
    [address_line_1, address_line_2, city, state, zip, country].compact.join(', ')
  end
end
