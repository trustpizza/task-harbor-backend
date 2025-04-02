class CreateTaskWorkflows < ActiveRecord::Migration[7.1]
  def change
    create_table :task_workflows do |t|
      t.references :task, null: false, foreign_key: true
      t.references :workflow, null: false, foreign_key: true

      t.timestamps
    end
  end
end
