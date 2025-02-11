class AddRequiredtoProejctFieldDefinitions < ActiveRecord::Migration[7.1]
  def change
    add_column :project_field_definitions, :required, :boolean, default: false
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
