class SessionsController < ApplicationController

  skip_before_filter :ensure_verified, :only => [:destroy]

  def new
    @title = "Login"
  end

  def create
    user = User.authenticate(params[:session][:email].to_s + "@student.umass.edu",
                             params[:session][:password])

    if user
      sign_in user
      redirect_back_or home_user_url(user)
    else
      params[:session][:password] = nil
      @title = "Login"
      @error = true  
     
      render :new
    end
  end

  def destroy
    name = current_user.username

    sign_out
    puts root_url.to_s + "dafasdfdsafadsfdsafs"
    redirect_to root_url
  end
end
