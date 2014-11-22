Sequel.migration do
  change do
    create_table(:builds) do
      primary_key :id
      String :version, :null => false, :size => 10
      String :fixes, :null => false, :size => 140
      DateTime :created_time, :null => false
      String :file_name, :null => false
      String :file_checksum, :null => false
      foreign_key :android_app_id, :android_apps
    end
  end
end
