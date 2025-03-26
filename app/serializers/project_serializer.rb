class ProjectSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :due_date, :creation_date, :organization_id, :project_manager_id

  has_many :fields, record_type: :fields
  has_many :field_definitions, record_type: :field_definitions
  has_many :field_values, record_type: :field_values
  has_many :tasks, record_type: :tasks
end