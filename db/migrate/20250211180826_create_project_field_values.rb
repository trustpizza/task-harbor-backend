class CreateProjectFieldValues < ActiveRecord::Migration[7.1]
  def change
    create_table :project_field_values do |t|
      t.text :value
      t.references :project, null: false, foreign_key: true
      t.references :project_field_definition, null: false, foreign_key: true

      t.timestamps
    end
  end
end
