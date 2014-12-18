Sequel.migration do
  change do
    add_column :builds, :type, String, :null => false, :default => ''
  end
end
