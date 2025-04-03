class AddPolymorphicAssociationToTasks < ActiveRecord::Migration[7.1]
  def change
    change_table :tasks do |t|
      t.references :taskable, polymorphic: true, null: false
    end
  end
end
