# app/serializers/organization_serializer.rb
class OrganizationSerializer
  include JSONAPI::Serializer

  attributes :name, :description # Add any other organization attributes you want to expose

  has_one :address
  has_many :users
  has_many :projects
end