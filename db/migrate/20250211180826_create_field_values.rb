class CreateFieldValues < ActiveRecord::Migration[7.1]
  def change
    create_table :field_values do |t|
      t.text :value

      t.timestamps
    end
  end
end
