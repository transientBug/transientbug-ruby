Sequel.migration do
  change do
    create_table :permits do
      primary_key :id

      Integer :resource_id,  null: false
      String :resource_type, null: false

      foreign_key :user_id, :users, index: true, null: false

      column :actions, 'text[]'

      DateTime :created_at
      DateTime :updated_at

      index [ :resource_id, :resource_type ]
    end
  end
end
