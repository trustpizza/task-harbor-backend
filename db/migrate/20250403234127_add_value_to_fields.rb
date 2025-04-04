class AddValueToFields < ActiveRecord::Migration[7.1]
  def change
    add_column :fields, :value, :text
  end
end
