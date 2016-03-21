module TransientBug
  module_function
  def pushbullet
    @@pushbullet ||= Washbullet::Client.new AshFrame.config_for(:pushbullet)[:key]
  end
end
