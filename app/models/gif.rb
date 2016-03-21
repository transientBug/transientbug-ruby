class Gif < Sequel::Model
  plugin :validation_helpers

  many_to_one :user

  def validate
    super
    validates_presence [ :user_id, :file_key ]
    validates_unique [ :file_key ]
  end
end
