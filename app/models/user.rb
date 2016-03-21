class User < Sequel::Model
  include Preferences
  include Permits
  include Groups

  plugin :validation_helpers
  plugin :secure_password, include_validations: false

  one_to_many :authorizations

  preference :notifications, default: true
  preference :image,         default: ''
  preference :email,         default: ''

  def validate
    super
    validates_presence [ :username ]
    validates_unique :username

    if password_confirmation.present?
      errors.add :password, "doesn't match confirmation" if password != password_confirmation
    end
  end
end
