module Preferences
  extend ActiveSupport::Concern

  class_methods do
    def preferences
      @@preferences ||= {}
    end

    def preference name, default: '', &block
      default = block if block_given? # Meh, just don't provide a default and a block at the same time

      preferences[name] = default
    end
  end

  included do
    one_to_many :preferences
  end

  def get_preference name
    p = Preference.find_or_create user: self, name: name.to_s do |preference|
      preference.value = nil
    end

    p.value
  end

  def set_preference(name, to:)
    p = Preference.update_or_create user: self, name: name.to_s do |preference|
      preference.value = to
    end

    p.value
  end

  protected

  def after_create
    self.class.preferences.each do |name, default|
     default = instance_eval(&default) if default.kind_of? Proc

     set_preference name, to: default
    end
  end
end
