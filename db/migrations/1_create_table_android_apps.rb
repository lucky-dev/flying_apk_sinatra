Sequel.migration do
  change do
    create_table(:android_apps) do
      primary_key :id
      String :name, :null => false, :size => 50
      String :description, :null => false, :size => 140
    end
  end
end
