class Group < Sequel::Model
  plugin :pg_array_associations
  plugin :validation_helpers

  pg_array_to_many :users

  def validate
    super
    validates_presence [ :name ]
  end

  class << self
    def by_name n
      find_or_create name: n.to_s
    end
  end
end
