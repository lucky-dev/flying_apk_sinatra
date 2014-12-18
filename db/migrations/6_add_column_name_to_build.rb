Sequel.migration do
  change do
    add_column :builds, :name, String, :null => false, :default => ''
  end
end
