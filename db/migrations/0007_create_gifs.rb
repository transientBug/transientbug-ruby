Sequel.migration do
  change do

    create_table :gifs do
      primary_key :id

      String :file_key, unique: true, index: true, null: false

      String :title
      column :tags, 'text[]'

      foreign_key :user_id, :users, index: true

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
