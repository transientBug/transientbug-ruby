require './app'
# require 'sidekiq/web'

run Rack::URLMap.new('/' => IndexController) # , '/sidekiq' => Sidekiq::Web)

trap("INT"){ exit }
