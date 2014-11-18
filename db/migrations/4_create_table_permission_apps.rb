Sequel.migration do
  change do
    create_table(:permission_apps) do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :android_app_id, :android_apps
      String :permission, :null => false
    end
  end
end
