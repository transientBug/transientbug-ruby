module AuthenticationHelper
  def current_user
    @current_user ||= User.find id: session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def authenticate!
    return if logged_in?

    session[:return_path] = request.path
    flash[:error]         = "You need to login to access that"

    halt redirect(to('/login'))
  end

  def authorize! resource:, action: nil
    return if current_user.can? resource: resource, action: action

    flash[:error] = "You are not authorized to do that"

    half redirect(to('/'))
  end
end
