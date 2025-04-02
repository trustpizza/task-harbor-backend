# app/serializers/task_serializer.rb
class TaskSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :due_date, :created_at, :updated_at

  # belongs_to :project
  # has_many :field_definitions
  # has_many :workflows
  has_many :fields, serializer: FieldSerializer
  has_many :field_values
end