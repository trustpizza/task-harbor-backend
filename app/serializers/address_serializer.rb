# app/serializers/address_serializer.rb
class AddressSerializer
  include JSONAPI::Serializer

  attributes :address_line_1, :address_line_2, :city, :state, :zip, :country, :latitude, :longitude

  attribute :full_address # Add full_address attribute if needed
  attribute :geocoded_address # Add geocoded_address attribute if needed

  belongs_to :addressable, polymorphic: true
end