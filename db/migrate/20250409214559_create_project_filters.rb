class CreateProjectFilters < ActiveRecord::Migration[7.1]
  def change
    create_table :project_filters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.jsonb :criteria

      t.timestamps
    end
  end
end
