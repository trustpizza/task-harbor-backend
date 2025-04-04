# app/serializers/field_serializer.rb
class FieldSerializer
  include JSONAPI::Serializer

  attributes :fieldable_type, :fieldable_id, :value # Include these for polymorphic association
  
  belongs_to :field_definition, serializer: FieldDefinitionSerializer
  # belongs_to :fieldable, polymorphic: true
end