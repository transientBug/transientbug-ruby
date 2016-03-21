class Permit < Sequel::Model
  plugin :validation_helpers

  many_to_one :resource, polymorphic: true
  many_to_one :user

  def validate
    super
    validates_presence [ :user_id, :resource_id, :resource_type ]
  end

  class << self
    def allow! user:, resource:, actions: []
      permit = find_or_create user: user, resource_id: resource.id, resource_type: resource.class.to_s
      permit.actions = Array(actions).map(&:to_s)
      permit.save
    end

    def disallow! user:, resource:, actions: []
      permit = find_or_create user: user, resource_id: resource.id, resource_type: resource.class.to_s
      permit.actions = permit.actions - Array(actions).map(&:to_s)
      permit.save
    end

    def can? user:, resource:, action: nil
      permit = find user: user, resource_id: resource.id, resource_type: resource.class.to_s

      return false unless permit
      return permit.actions.include? action.to_s
    end
  end
end
