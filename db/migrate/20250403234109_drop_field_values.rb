class DropFieldValues < ActiveRecord::Migration[7.1]
  def change
    drop_table :field_values
  end
end
