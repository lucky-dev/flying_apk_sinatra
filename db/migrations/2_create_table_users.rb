Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :name, :null => false, :size => 50
      String :email, :null => false, :unique=>true
      String :encoded_password, :null => false
      String :access_token, :null => false, :default => ''
    end
  end
end
