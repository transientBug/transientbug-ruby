module Permits
  extend ActiveSupport::Concern

  included do
    one_to_many :permits
  end

  def allow! resource:, actions: []
    Permit.allow! user: self, resource: resource, actions: actions
  end

  def disallow! resource:, actions: []
    Permit.disallow! user: self, resource: resource, actions: actions
  end

  def can? resource:, action: nil
    Permit.can? user: self, resource: resource, action: action.to_s
  end
end
