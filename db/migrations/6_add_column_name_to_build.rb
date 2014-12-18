Sequel.migration do
  change do
    add_column :builds, :name, String, :null => false, :size => 50, :default => ''
  end
end
