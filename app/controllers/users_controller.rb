class UsersController < ApplicationController
  before_filter :authenticate, :except => [:new, :forgot_password, :post_forgot_password, :create, :destroy, :index]
  before_filter :correct_user, :except => [:show, :index, :for_sale_listings, :looking_for_listings, :destroy ]
  before_filter :approved_user, :only => [:destroy ]
  before_filter :authenticate_admin, :only => [:index]
  before_filter :not_logged_in, :only => [:new, :create]

  skip_before_filter :ensure_verified, :except => [:show, :for_sale_listings, :looking_for_listings, :deals, :deals_made, :recieved_offers, :sent_offers ]

  before_filter :set_user_current_user, :only => [:home, :notifications, :deals_made, :post_verify, :update, :recieved_offers, :sent_offers, :settings]
  before_filter :set_user, :except => [:index, :new, :home , :forgot_password, :post_forgot_password, :create ]


  def index
    @users = User.paginate(:page => params[:page])
    @title = "All Users"
  end

  def show
    @title = @user.username
  end

  def home
    @title = "Home"
  end

  def new
    @user = User.new
    @title = "Sign up!"
  end

  def notifications
    @title = "Notifications"
  end

  def for_sale_listings
    @title = "#{@user.username}'s 'For Sale' listings"
    @title = "Your 'For Sale' listings" if @user.id == current_user.id
    @listings = @user.sell_listings.paginate(:page => params[:page])
  end

  def looking_for_listings
    @title = "#{@user.username}'s 'Looking For' listings"
    @title = "Your 'Looking For' listings" if @user.id == current_user.id
    @listings = @user.buy_listings.paginate(:page => params[:page])
  end

  def settings
    @title = "Settings"
  end

  def deals_made
    @deals = (@user.deals_bought.where('buyer_status > 0') + @user.deals_sold.where('seller_status > 0')).paginate(:page => params[:page], :per_page => 5)
  end

  def deals
    @deals = @user.new_deals.paginate(:page => params[:page], :per_page => 5)
  end

  def verify
    @title = "Account Verification"
  end

  def new_verification_token
    UserMailer.verify_notification(@user, @user.make_verify_token!).deliver

    redirect_to verify_user_path(@user), :notice => "New verification token created and emailed to #{@user.email}"
  end

  def post_verify
    token = params[:token]

    if @user.verified? == false && @user.verify!(token)
      @user.notify("Your account has been verified!")
      redirect_to home_user_path(@user), :notice => "Your account has been verified!"
    else
      if @user.verified?
        redirect_to home_user_path(@user), :notice => 'Your account has already been verified'
	return
      end
      redirect_to verify_user_path(@user), :notice => "Token didn't match our records"
    end
  end

  def forgot_password
    @title = "Forgot Password"
  end

  def post_forgot_password
    @user = User.find_by_email(params[:user].to_s.downcase + "@student.umass.edu")

    if @user.nil?
      redirect_to forgot_password_users_path, :notice => "We couldn't find a user with that email address"
      return
    end

    UserMailer.forgot_password_notification(@user, @user.make_forgot_password_token!).deliver

    redirect_to signin_path, :notice => "A new password has been sent to #{@user.username} at #{@user.email}"
  end

  def create
    params[:user][:location] = User.index_from_location params[:user][:location]
    params[:user][:email].downcase!
    @user = User.new(params[:user])
    puts @user.location

    if @user.save
      User.increase_count
      UserMailer.verify_notification(@user, @user.make_verify_token!).deliver
      sign_in_for_first_time(@user)
    else
      user = User.find_by_email(@user.email.downcase)
      if user.nil? == false && user.verified? == false
        user.destroy

	if @user.save
	  UserMailer.verify_notification(@user, @user.make_verify_token!).deliver
	  sign_in_for_first_time(@user)
	  return
	end
      end
      @user.password = ""
      @user.password_confirmation = ""
      render :action => "new"
    end
  end

  def update
    params[:user][:location] = User.index_from_location params[:user][:location]

    if @user.update_attributes(params[:user])
      sign_in @user
      redirect_to home_user_path, :notice => 'Settings Updated!'
    else
      @user.current_password = ""
      @user.password = ""
     @user.password_confirmation = ""
      render :settings
    end
  end

  def recieved_offers
    @title = "Offers"
    @offers = current_user.recieved_offers.paginate(:page => params[:page])
  end

  def sent_offers
    @title = "Sent Offers"
    @offers = current_user.sent_offers.paginate(:page => params[:page])
  end

  def deals
    @title = "Deals Pending"
    @deals = current_user.deals.paginate(:page => params[:page], :per_page => 5)
  end

  def destroy
    if @user.admin?
      redirect_to @user, :notice => "You can't delete an administrator!"
      return
    end

    @user.destroy
    User.decrease_count

    if !current_user.nil? && current_user.admin?
      redirect_to users_url, :notice => "You successfully destroyed the user, #{@user.username}, with ID: #{@user.id}"
    else  
      sign_out
      redirect_to root_path, :notice => "#{@user.username}, you have successfully destroyed your account"
    end
  end

  private

    def sign_in_for_first_time(user)
      sign_in user
      user.notify("Congratulations on creating a Campus Books account. You must verify your account before you can fully utilize this site. We sent a verification link to (#{user.email}).")
      redirect_back_or(home_user_path(user), 'A verification email has been sent. Please verify your account before continuing.')
    end

    def set_user
      return if @user
      @user = User.find_by_id(params[:id])
      redirect_to root_path if @user.nil?
    end

    def set_user_current_user
      @user = current_user
    end
end
