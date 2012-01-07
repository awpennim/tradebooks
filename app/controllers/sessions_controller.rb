class SessionsController < ApplicationController
  def new
    @title = "Sign In"
  end

  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])

    if user
      sign_in user
      redirect_back_or user
    else
      params[:session][:password] = nil
      @title = "Sign in"
      @error = true  
     
      render 'new'
    end
  end

  def destroy
    name = current_user.username

    sign_out
    redirect_to root_path, :notice => "#{name}, you have been successfully logged out"
  end

end
