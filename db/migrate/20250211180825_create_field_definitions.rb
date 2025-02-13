class CreateFieldDefinitions < ActiveRecord::Migration[7.1]
  def change
    create_table :field_definitions do |t|
      t.string :name
      t.string :field_type
      t.text :options
      t.boolean :required, null: false, :default => false

      t.timestamps
    end
  end
end
