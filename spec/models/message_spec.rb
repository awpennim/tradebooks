require 'spec_helper'

describe Message do

  before(:each) do
    @user1 = User.create!(:email => "1@student.umass.edu", :password => "foobar", :password_confirmation => "foobar")
    @user2 = User.create!(:email => "2@student.umass.edu", :password => "foobar", :password_confirmation => "foobar")
  end

  it "should save valid message" do
    message = @user1.sent_messages.build(:text =>"dafssdf", :reciever_id => @user2.id)

    message.should be_valid
  end

  it "shouldn't save without a reciever" do
    message = @user1.sent_messages.build(:text => "adfs")

    message.should_not be_valid
  end

  it "shouldn't save without a message" do
    message = @user1.sent_messages.build(:reciever_id => @user2.id)

    message.should_not be_valid
  end

end
