class ProjectFieldValue < ApplicationRecord
  belongs_to :project
  belongs_to :project_field_definition
end
