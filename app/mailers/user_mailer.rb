class UserMailer < ActionMailer::Base
  default :from => "no_reply@tradecampusbooks.com"

  def verify_notification(user, token)
    @user = user
    @token = token
    mail(:to => user.email, :subject => "Please activate your Trade Campus Books account")
  end

  def forgot_password_notification(user,token)
    @user = user
    @token = token
    mail(:to => user.email, :subject => "#{user.username}, Your New Password")
  end

  def send_textbook_request_to_admin(request, user)
    @user = user
    @request = request
    mail(:to => "apenniman@tradecampusbooks.com", :subject => "#{user.username}'s textbook request")
  end
  
  def alert_admin_new_user(user)
    @user = user
    mail(:to => "apenniman@tradecampusbooks.com", :subject => "#{user.email}, created an account", :from => "support@tradecampusbooks.com")
  end

  def alert_admin_new_listing(listing)
    @user = listing.poster
    if listing.selling?
      mail(:to => "apenniman@tradecampusbooks.com", :subject => "#{@user.username}, with id: #{@user.id}, posted a new 'For Sale' listing", :from => "support@tradecampusbooks.com")
    else
      mail(:to => "apenniman@tradecampusbooks.com", :subject => "#{@user.username}, with id: #{@user.id}, posted a new 'Looking For' listing", :from => "support@tradecampusbooks.com")
    end
  end
end
