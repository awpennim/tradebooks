class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  before_filter :ensure_verified, :if => :logged_in?
  before_filter :ensure_domain
  before_filter :check_notifications, :if => :logged_in?

  APP_DOMAIN = 'www.tradecampusbooks.com'

  def ensure_domain
    if Rails.env.production? && request.env['HTTP_HOST'] != APP_DOMAIN
      redirect_to "http://#{APP_DOMAIN}", :status => 301
    end
  end

  def check_notifications
    @notifications = current_user.notifications
  end
end
