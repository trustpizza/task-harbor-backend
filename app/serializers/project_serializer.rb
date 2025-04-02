class ProjectSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :due_date, :project_manager_id, :created_at, :updated_at

  has_many :tasks, serializer: TaskSerializer
  has_many :workflows, serializer: WorkflowSerializer
  has_many :fields, serializer: FieldSerializer
  has_many :field_definitions, serializer: FieldDefinitionSerializer
  has_many :field_values, serializer: FieldValueSerializer
end