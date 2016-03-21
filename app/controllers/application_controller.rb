class ApplicationController < BaseController
  use HealthController
  use AuthenticationController

  get '/' do
  end
end
