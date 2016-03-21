class Authorization < Sequel::Model
  plugin :validation_helpers

  many_to_one :user

  def validate
    super
    validates_presence [ :user_id, :provider, :uid ]
    validates_unique [ :uid, :provider ]
  end
end
