module Groups
  extend ActiveSupport::Concern

  included do
    plugin :pg_array_associations

    many_to_pg_array :groups
  end

  def in_group? group
    group = group.to_s
    groups.any?{ |g| g.name == group }
  end
end
