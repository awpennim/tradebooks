class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update, :show, :home, :verify]
  before_filter :correct_user, :only => [:edit, :update, :home, :verify ]
  before_filter :approved_user, :only => [:show, :destroy, :show]
  before_filter :authenticate_admin, :only => [:index]
  before_filter :not_logged_in, :only => [:new, :create]

  skip_before_filter :ensure_verified, :except => [:show]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def home
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def settings
    @user = User.find_by_id(params[:id])
  end

  def verify
    @user = User.find(params[:id])
  end

  def post_verify
    token = params[:token]
    @user = User.find(params[:id])

    if @user.verify! token
      redirect_to home_user_path(@user), :notice => "Your account has been verified!"
    else
      redirect_to verify_user_path(@user), :notice => "Token didn't match our records"
    end
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      sign_in @user
      redirect_to(home_user_path(@user), :notice => 'User was successfully created.')
    else
      puts @user.id.to_s + "better not work"
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])

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

    id = @user.id
    @user.destroy

    if current_user.admin?
      redirect_to users_url, :notice => "You successfully destroyed the user, #{@user.username}, with ID: #{id}"
    else  
      sign_out
      redirect_to root_path, :notice => "#{@user.username}, you have successfully destroyed your account"
    end
  end

  def admin?
    admin
  end

  private

end
