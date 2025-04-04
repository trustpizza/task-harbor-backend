class CreateProjectWorkflows < ActiveRecord::Migration[7.1]
  def change
    create_table :project_workflows do |t|
      t.references :project, null: false, foreign_key: true
      t.references :workflow, null: false, foreign_key: true

      t.timestamps
    end
    add_index :project_workflows, [:project_id, :workflow_id], unique: true
  end
end
