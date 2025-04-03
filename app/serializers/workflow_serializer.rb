class WorkflowSerializer
  include JSONAPI::Serializer

  attributes :name, :description
  belongs_to :organization # Added organization relationship
  has_many :tasks
end