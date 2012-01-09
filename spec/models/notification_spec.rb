require 'spec_helper'

describe Notification do
  before(:each) do
    @user = User.create!(:password => "foobar", :password_confirmation => "foobar", :email => "a@student.umass.edu")

    @attr = {:message => "foobar"}
  end

  it "should save valid" do
    note = @user.notifications.build(@attr)

    note.should be_valid
  end

  it "should not save no message" do
    note = @user.notifications.build(@attr.merge(:message => ""))

    note.should_not be_valid
  end

  it "should not save nil message" do
    note = @user.notifications.build(@attr.merge(:message => nil))

    note.should_not be_valid
  end

  it "should not save without a user_id" do
    note = Notification.new(@attr)

    note.should_not be_valid
  end
end
