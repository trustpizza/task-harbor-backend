class CreateProjectFieldDefinitions < ActiveRecord::Migration[7.1]
  def change
    create_table :project_field_definitions do |t|
      t.string :name
      t.string :field_type
      t.text :options
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
