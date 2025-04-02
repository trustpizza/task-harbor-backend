class WorkflowSerializer
  include JSONAPI::Serializer

  has_and_belongs_to_many :tasks
end