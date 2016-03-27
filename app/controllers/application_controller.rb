require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/flash'

require 'haml'
require 'tilt/haml'

require 'rabl'

require 'erb'
require 'tilt/erb'

Rabl.register!

class ApplicationController < Sinatra::Base
  set :views,         -> { AshFrame.root.join 'app/views' }
  set :public_folder, -> { AshFrame.root.join 'public' }

  # enable :sessions

  use Rack::Session::Cookie
  # use OmniAuth::Builder do
  # end

  helpers Sinatra::ContentFor
  register Sinatra::Flash

  # Setup logging for access and error logs, just for niceness.
  use Rack::CommonLogger, AshFrame.logger
  ::Logger.class_eval{ alias :write :'<<' }
  access_log        = AshFrame.root.join('logs','access.log')
  access_logger     = ::Logger.new(access_log)
  error_logger      = ::File.new(AshFrame.root.join('logs','error.log'), "a+")
  error_logger.sync = true

  configure do
    use ::Rack::CommonLogger, access_logger
  end

  before do
    env["rack.errors"] = error_logger
  end

  helpers PartialHelper, AuthenticationHelper, FlashHelper, ReactHelper
end
