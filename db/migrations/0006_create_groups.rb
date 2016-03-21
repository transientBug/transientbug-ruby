Sequel.migration do
  change do

    create_table :groups do
      primary_key :id

      String :name, unique: true, index: true, null: false
      column :user_ids, 'integer[]'

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
