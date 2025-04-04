class ProjectWorkflow < ApplicationRecord
  belongs_to :project
  belongs_to :workflow
end
