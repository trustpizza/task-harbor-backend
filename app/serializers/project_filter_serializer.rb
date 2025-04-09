class ProjectFilterSerializer
  include JSONAPI::Serializer
  attributes :name, :criteria, :created_at, :updated_at
end

