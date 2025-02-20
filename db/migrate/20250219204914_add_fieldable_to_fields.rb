class AddFieldableToFields < ActiveRecord::Migration[7.0]
  def change
    remove_reference :fields, :project, foreign_key: true, if_exists: true
    add_reference :fields, :fieldable, polymorphic: true, null: true
  end
end