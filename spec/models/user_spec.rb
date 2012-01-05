require 'spec_helper'

describe User do

  before(:each) do
    @attr = {:email => "awpennim@student.umass.edu", 
             :password => "foobar", 
	     :password_confirmation => "foobar"}
  end

  it "should save valid" do
    user = User.new(@attr)
    puts user
    puts user.username
    user.should be_valid
  end

  it "shouldnt save an invalid email" do
    user = User.new(@attr.merge(:email => "awpennim@studentumass.edu"))

    user.should_not be_valid
  end

  it "shouldnt save a short password" do
    user = User.new(@attr.merge(:password => "foo", :password_confirmation => "foo"))

    user.should_not be_valid
  end

  it "shouldnt save a password too long" do
    User.new(@attr.merge(:password => ("a" * 31), :password_confirmation => ("a" * 31))).should_not be_valid
  end

  it "should get the right username" do
    User.new(@attr).username.should == "awpennim"
  end
end
