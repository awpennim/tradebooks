class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include ReCaptcha::AppHelper

  before_filter :ensure_verified, :if => :logged_in?
  before_filter :ensure_domain

  APP_DOMAIN = 'www.tradecampusbooks.com'

  def ensure_domain
    if Rails.env.production? && request.env['HTTP_HOST'] != APP_DOMAIN
      redirect_to "http://#{APP_DOMAIN}", :status => 301
    end
  end
end
