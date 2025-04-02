class WorkflowSerializer
  include JSONAPI::Serializer

  attributes :name, :description
  has_many :tasks
end