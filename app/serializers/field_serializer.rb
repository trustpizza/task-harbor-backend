# app/serializers/field_serializer.rb
class FieldSerializer
  include JSONAPI::Serializer

  attributes :fieldable_type, :fieldable_id # Include these for polymorphic association

  belongs_to :field_definition
  belongs_to :fieldable, polymorphic: true
  has_many :field_values
end