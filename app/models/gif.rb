class Gif < Sequel::Model
  plugin :validation_helpers

  many_to_one :user

  def validate
    super
    validates_presence [ :user_id, :filename, :short_code ]
    validates_unique [ :filename, :short_code ]
  end
end
