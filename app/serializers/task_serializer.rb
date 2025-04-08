# app/serializers/task_serializer.rb
class TaskSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :due_date, :created_at, :updated_at

  belongs_to :taskable, polymorphic: true
  has_many :fields, serializer: FieldSerializer, if: proc { |record, params| params[:include]&.include?('fields') }

  # Include nested relationships for fields
  has_many :field_definitions, through: :fields
end