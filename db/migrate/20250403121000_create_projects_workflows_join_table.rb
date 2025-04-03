class CreateProjectsWorkflowsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :projects, :workflows do |t|
      t.index :project_id
      t.index :workflow_id
    end
  end
end
