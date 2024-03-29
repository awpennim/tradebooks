module SessionsHelper
  def authenticate
    deny_access unless logged_in?
  end

  def deny_access
    store_location
    redirect_to signin_url
    flash[:notice] = "You must be logged in to do that"
  end

  def store_location
    session[:return_to] = request.url
  end

  def clear_return_to
    session[:return_to] = nil
  end

  def redirect_back_or(default, notice = nil)
    temp = session[:return_to]

    clear_return_to
    if temp
      redirect_to temp, :notice => notice
    else
      redirect_to default
    end
  end

  def authenticate_admin
    if current_user.nil?
      store_location
      redirect_to signin_url, :notice => "You must be logged in to do that"
      return
    end
    unless current_user.admin?
      redirect_to home_user_url(current_user), :notice => "You don't have permission to view that page"
    end
  end

  def approved_user
    redirect_to home_user_url(current_user), :notice => "You do no have permission to view that page" if current_user.id.to_s != params[:id] && !current_user.admin?
  end

  def correct_user
    redirect_to home_user_url(current_user), :notice => "You do not have permission to view that page" if logged_in? && params[:id] != current_user.id.to_s
  end

  def current_user
    @current_user || user_from_remember_token
  end

  def logged_in?
    current_user.nil? == false
  end

  def not_logged_in
    redirect_to home_user_url(current_user), :notice => "You are already logged in!" if logged_in?
  end

  def sign_in user
    session[:remember_token_id] = user.id
    session[:remember_token_salt] = user.salt
    self.current_user = user
  end

  def sign_out
    session[:remember_token_id] = nil
    session[:remember_token_salt] = nil
  end

  def current_user= (user)
    @current_user = user
  end

  def current_user?(user)
    user == current_user
  end

  def ensure_verified
    redirect_to home_user_url(current_user), :notice => "You must verify your account first!" unless current_user.verified?
  end

  private

    def user_from_remember_token
      user = User.authenticate_with_salt(*remember_token)
      current_user = user
    end

    def remember_token
      [(session[:remember_token_id] || nil),(session[:remember_token_salt] || nil)]
    end
end

