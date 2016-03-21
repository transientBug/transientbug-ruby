Sequel.migration do
  change do
    create_table :features do
      primary_key :id

      String :namespace, index: true
      String :name,      index: true, null: false

      FalseClass :enabled, default: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
