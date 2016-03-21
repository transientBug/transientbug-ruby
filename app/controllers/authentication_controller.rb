class AuthenticationController < BaseController
  # Session handling

  get '/login' do
    return haml :login unless logged_in?

    redirect to('/')
  end

  post '/login' do
    identity = params['username'].downcase

    user = User.find{ lower(username) =~ identity }

    if user.blank?
      flash.now[:error] = "User or Password does not match"
      return haml :login
    end

    unless user.authenticate(params['password'])
      flash.now[:error] = "User or Password does not match"
      return haml :login
    end

    session[:user_id] = user.id
    @current_user = user

    path = session[:return_path] || '/'
    redirect to(path)
  end

  get '/logout' do
    session[:user_id] = nil

    redirect to('/')
  end

  # omniauth template
  # get '/auth/:provider/callback' do
  # end
end
