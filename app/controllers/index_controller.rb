class IndexController < ApplicationController
  use HealthController
  use AuthenticationController
  use GifController

  get '/' do
    redirect to('/gifs') unless logged_in?

    haml :index
  end
end
