Sequel.migration do
  change do
    create_table :preferences do
      primary_key :id

      String :name, index: true
      text :value

      foreign_key :user_id, :users, index: true

      DateTime :created_at
      DateTime :updated_at

      index [ :name, :user_id ]
    end
  end
end
