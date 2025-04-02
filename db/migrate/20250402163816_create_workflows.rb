class CreateWorkflows < ActiveRecord::Migration[7.1]
  def change
    create_table :workflows do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
