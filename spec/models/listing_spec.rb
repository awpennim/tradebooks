require 'spec_helper'

describe Listing do
  before(:each) do
    @user = User.create!(:email => "foobar@student.umass.edu", :password => "foobar", :password_confirmation => "foobar")
    @attr = {:price => 299.99, :textbook_id => 1}
  end

  it "should save selling valid" do
    @user.sell_listings.build(@attr).should be_valid
  end

  it "should save buying valid" do
    @user.buy_listings.build(@attr).should be_valid
  end

  it "shouldn't save price too big" do
    @user.sell_listings.build(@attr.merge(:price => 300.00)).should_not be_valid
  end

  it "shouldn't save price == 0" do
    @user.sell_listings.build(@attr.merge(:price => 0.00)).should_not be_valid
  end

  it "shouldn't save without a textbook_id" do
    @user.sell_listings.build(@attr.merge(:textbook_id => nil)).should_not be_valid
  end
end
