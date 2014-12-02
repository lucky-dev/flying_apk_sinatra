Sequel.migration do
  change do
    create_table(:access_tokens) do
      primary_key :id
      foreign_key :user_id, :users
      String :access_token, :null => false
    end
  end
end
