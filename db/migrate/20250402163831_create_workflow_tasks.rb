class CreateWorkflowTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :workflow_tasks do |t|
      t.references :workflow, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
