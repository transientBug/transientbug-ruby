require 'tilt/erb'
require 'yaml'

require 'active_support/all'

module AshFrame
  module_function

  def root= path
    @@root = Pathname.new path
  end

  def root
    @@root ||= Pathname.new File.dirname(__FILE__)
  end

  def environment
    @@env ||= (ENV['RACK_ENV'] || :development).to_sym
  end

  # Shamelessly stolen, then cleaned up a bit, from the [Rails project](https://github.com/rails/rails/blob/0450642c27af3af35b449208b21695fd55c30f90/railties/lib/rails/application.rb#L218-L231)
  def config_for name
    yaml = AshFrame.root.join 'config', "#{ name }.yml"

    unless yaml.exist?
      raise "Could not load configuration. No such file - #{ yaml }"
    end

    erb = ERB.new(yaml.read).result
    erbd_yaml = YAML.load erb

    erbd_yaml[AshFrame.environment.to_s] || {}
  rescue YAML::SyntaxError => e
    raise "YAML syntax error occurred while parsing #{ yaml }. " \
      "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
      "Error: #{ e.message }"
  end
end
