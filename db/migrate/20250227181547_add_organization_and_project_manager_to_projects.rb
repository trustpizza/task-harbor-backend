class AddOrganizationAndProjectManagerToProjects < ActiveRecord::Migration[7.1]
  def change
    add_reference :projects, :organization, null: false, foreign_key: true
    add_reference :projects, :project_manager, polymorphic: true, null: false
  end
end
