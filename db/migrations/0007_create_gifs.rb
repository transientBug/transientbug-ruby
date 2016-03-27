Sequel.migration do
  change do

    create_table :gifs do
      primary_key :id

      String :filename,   unique: true, index: true, null: false
      String :short_code, unique: true, index: true, null: false

      String :title
      column :tags, 'text[]'

      foreign_key :user_id, :users, index: true

      TrueClass :enabled, default: true, index: true

      DateTime :created_at
      DateTime :updated_at
    end

    create_view :tags, "SELECT DISTINCT unnest(tags) as tag FROM gifs"

  end
end
