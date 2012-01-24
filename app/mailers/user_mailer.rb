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

  def deal_made_buying_notification(offer)
    @user = offer.sender
    @other_user = offer.reciever
    @offer = offer
    mail(:to => @user.email, :subject => "Congratulations, #{@other_user.username}, accepted your purchase offer")
  end

  def deal_made_selling_notification(offer)
    @user = offer.sender
    @other_user = offer.reciever
    @offer = offer
    mail(:to => @user.email, :subject => "Congratulations, #{@other_user.username}, accepted your sales offer")
  end

  def sales_offer_recieved_notification(user, offer)
    @user = user
    @offer = offer
    mail(:to => user.email, :subject => "You recieved a sales offer for '#{offer.textbook.title_short}' from '#{offer.sender.username}'")
  end

  def purchase_offer_recieved_notification(user, offer)
    @user = user
    @offer = offer
    mail(:to => user.email, :subject => "You recieved a purchase offer for '#{offer.textbook.title_short}' from '#{offer.sender.username}'")
  end

  def send_textbook_request_to_admin(request, user)
    @user = user
    @request = request
    mail(:to => "support@tradecampusbooks.com", :subject => "Textbook Request")
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
