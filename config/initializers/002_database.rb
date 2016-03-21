require 'pg'
require 'sequel'

# Setup our SQL database for things
DB = Sequel.connect(
  **AshFrame.config_for(:database).symbolize_keys,
  loggers: [ Logger.new(AshFrame.root.join('logs', 'sql.log')) ]
)

DB.extension :pagination

Sequel::Model.db = DB

Sequel.default_timezone = :utc

DB.extension :pg_array, :pg_json, :pg_enum
DB.extension :pagination

# Sequel::Model.plugin :active_model
Sequel::Model.plugin :update_or_create

Sequel::Model.plugin :dirty
Sequel::Model.plugin :auto_validations
Sequel::Model.plugin :boolean_readers
Sequel::Model.plugin :timestamps, update_on_create: true

Sequel.extension :pg_json_ops, :pg_array_ops
