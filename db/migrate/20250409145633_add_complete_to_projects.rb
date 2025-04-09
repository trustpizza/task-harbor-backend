class AddCompleteToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :is_complete, :boolean, default: false
  end
end
