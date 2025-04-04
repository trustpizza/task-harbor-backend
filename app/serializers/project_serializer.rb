class ProjectSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :due_date, :project_manager_id, :created_at, :updated_at
 
  if proc { |record, params| params[:include]&.include?('all') }
    has_many :tasks, serializer: TaskSerializer
    has_many :workflows, serializer: WorkflowSerializer
    has_many :fields, serializer: FieldSerializer
    has_many :field_definitions, serializer: FieldDefinitionSerializer
  end

  has_many :tasks, serializer: TaskSerializer, if: proc { |record, params| params[:include]&.include?('tasks') }
  has_many :workflows, serializer: WorkflowSerializer, if: proc { |record, params| params[:include]&.include?('workflows') }
  has_many :fields, serializer: FieldSerializer, if: proc { |record, params| params[:include]&.include?('fields') }
  has_many :field_definitions, serializer: FieldDefinitionSerializer, if: proc { |record, params| params[:include]&.include?('field_definitions') }
end