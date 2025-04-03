# app/serializers/field_serializer.rb
class FieldSerializer
  include JSONAPI::Serializer

  attributes :fieldable_type, :fieldable_id # Include these for polymorphic association

  has_one :field_value, serializer: FieldValueSerializer
  # belongs_to :fieldable, polymorphic: true
  # belongs_to :field_definition, serializer: FieldDefinitionSerializer
end