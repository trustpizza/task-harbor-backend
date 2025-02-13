class CreateFields < ActiveRecord::Migration[7.1]
  def change
    create_table :fields do |t|
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
