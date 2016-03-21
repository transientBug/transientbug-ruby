class HealthController < BaseController
  # Health endpoint for dokku to hit to ensure that the app deployed well
  get '/ping' do
    'pong'
  end
end
