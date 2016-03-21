Sequel.migration do
  change do
    create_table :authorizations do
      primary_key :id

      String :provider
      String :uid

      foreign_key :user_id, :users, index: true

      column :info, :jsonb

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
