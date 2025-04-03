class CreateWorkflows < ActiveRecord::Migration[7.1]
  def change
    create_table :workflows do |t|
      t.string :name
      t.text :description
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
