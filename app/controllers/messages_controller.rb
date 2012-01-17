class MessagesController < ApplicationController
  before_filter :approved_user, :only => [:show, :delete]
  before_filter :correct_user, :only => [:new] 

  skip_before_filter 

  def show
    @message = Message.find(params[:id])
  end

  def new
    if params[:to] && User.find_by_username(params[:to]).nil? == false
      @user = User.find_by_username(params[:to])
      @title = "Compose Message to #{@user.username}"
    else
      @title = "Compose Message"
    end

    @message = Message.new
  end

  def inbox
    @title = "Inbox"
    @messages = current_user.recieved_messages
  end

  def outbox
    @title = "Outbox"
    @messages = current_user.sent_messages
  end

  def create
    @message = current_user.sent_messages.build(params[:message])

    if validate_recap(params, @message.errors, :msg => "You typed the authentication words incorrectly") && @message.save
      redirect_to(outbox_user_messages_path(current_user), :notice => "Your message has been sent")
    else
      render :action => "new"
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    redirect_to inbox_user_messages_path(current_user), :notice => "Message deleted"
  end

  private

    def approved_user #called when show and destroy
      redirect_to home_user_path(current_user), :notice => "A message with that ID couldn't be found" if Message.find_by_id(params[:id]).nil?
      redirect_to home_user_path(current_user), :notice => "You don't have permission to view that page" if Message.find_by_id(params[:id]).approved_user?(current_user) == false
      return true
    end

    def correct_user
      redirect_to home_user_path(current_user), :notice => "You don't have permission to view that page" if current_user.id.to_s != params[:user_id]
    end
end
