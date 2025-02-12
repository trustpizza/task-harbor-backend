class CreateFieldValues < ActiveRecord::Migration[7.1]
  def change
    create_table :field_values do |t|
      t.text :value
      t.references :project, null: false, foreign_key: true
      t.references :field_definition, null: false, foreign_key: true

      t.timestamps
    end
  end
end
