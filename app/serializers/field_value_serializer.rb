# app/serializers/field_value_serializer.rb
class FieldValueSerializer
  include JSONAPI::Serializer

  attributes :value

  belongs_to :field

  # If you want to include the field_type directly, you could do this:
  attribute :field_type do |record|
    record.field_definition&.field_type
  end
end