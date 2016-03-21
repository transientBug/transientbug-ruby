class Preference < Sequel::Model
  plugin :serialization
  plugin :validation_helpers

  many_to_one :user

  serialize_attributes :marshal, :value

  def validate
    super
    validates_presence [ :name ]
    validates_unique [ :name, :user_id ]
  end
end
