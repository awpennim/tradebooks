class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update, :show, :home, :verify, :notifications, :looking_for_listings, :for_sale_listings]
  before_filter :correct_user, :only => [:edit, :update, :home, :verify, :notifications ]
  before_filter :approved_user, :only => [:destroy ]
  before_filter :authenticate_admin, :only => [:index]
  before_filter :not_logged_in, :only => [:new, :create]

  skip_before_filter :ensure_verified, :except => [:show ]

  def index
    @users = User.all
    @title = "All Users"
  end

  def show
    @user = User.find(params[:id])
    @title = @user.username
  end

  def home
    @user = current_user
    @title = "Home"
  end

  def new
    @user = User.new
    @title = "Sign up!"
  end

  def notifications
    @user = current_user
    @title = "Notifications"
  end

  def for_sale_listings
    @user = User.find_by_id(params[:id])
    @title = "#{@user.username}'s 'For Sale' listings"
    @listings = @user.sell_listings.paginate(:page => params[:page])
  end

  def looking_for_listings
    @user = User.find_by_id(params[:id])
    @title = "#{@user.username}'s 'Looking For' listings"
    @listings = @user.buy_listings.paginate(:page => params[:page])
  end

  def settings
    @user = User.find_by_id(params[:id])
    @title = "Settings"
  end

  def verify
    @user = User.find(params[:id])
    @title = "Account Verification"
  end

  def post_verify
    token = params[:token]
    @user = current_user

    if @user.verify! token
      @user.notify("Your account has been verified. You may now buy and sell books.")
      redirect_to home_user_path(@user), :notice => "Your account has been verified!"
    else
      redirect_to verify_user_path(@user), :notice => "Token didn't match our records"
    end
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      sign_in @user
      @user.notify("Congratulations on creating a Campus Books account. Make sure you verify your account so you can start buying and selling books to other UMass students.")
      redirect_to(home_user_path(@user), :notice => 'A verification email has been sent. Please verify your account before continuing.')
    else
      render :action => "new"
    end
  end

  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      sign_in @user
      redirect_to home_user_path, :notice => 'Settings Updated!'
    else
      render :settings
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user.admin?
      redirect_to @user, :notice => "You can't delete an administrator!"
      return
    end

    @user.destroy

    if !current_user.nil? && current_user.admin?
      redirect_to users_url, :notice => "You successfully destroyed the user, #{@user.username}, with ID: #{@user.id}"
    else  
      sign_out
      redirect_to root_path, :notice => "#{@user.username}, you have successfully destroyed your account"
    end
  end
end
