# app/serializers/project_serializer.rb
class ProjectSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :due_date, :creation_date

  belongs_to :organization
  belongs_to :project_manager, record_type: :user, id_method_name: :project_manager_id
  has_many :fields
  has_many :field_definitions
  has_many :field_values
  has_many :tasks
end