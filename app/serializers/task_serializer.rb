# app/serializers/task_serializer.rb
class TaskSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :due_date

  belongs_to :project
  has_many :fields
  has_many :field_definitions
  has_many :field_values
end