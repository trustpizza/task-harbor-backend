class ProjectSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :due_date, :project_manager_id, :created_at, :updated_at

  has_many :tasks, serializer: TaskSerializer, if: proc { |record, params| params[:include]&.include?('tasks') }
  has_many :workflows, serializer: WorkflowSerializer, if: proc { |record, params| params[:include]&.include?('workflows') }
  has_many :fields, serializer: FieldSerializer, if: proc { |record, params| params[:include]&.include?('fields') }
  has_many :field_definitions, serializer: FieldDefinitionSerializer, if: proc { |record, params| params[:include]&.include?('field_definitions') }
  has_many :field_values, serializer: FieldValueSerializer, if: proc { |record, params| params[:include]&.include?('field_values') }
end