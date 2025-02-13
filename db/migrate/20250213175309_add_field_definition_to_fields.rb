class AddFieldDefinitionToFields < ActiveRecord::Migration[7.1]
  def change
    add_reference :fields, :field_definition, null: false, foreign_key: true, index: true
    add_reference :field_values, :field, null: false, foreign_key: true, index: true
  end
end
