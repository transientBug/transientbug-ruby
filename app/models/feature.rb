class Feature < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [ :name ]
  end

  class << self
    def by_name n, namespace: nil
      find_or_create name: n.to_s, namespace: namespace.to_s
    end
  end
end
