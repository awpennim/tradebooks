require 'spec_helper'

describe HelpController do

  describe "GET 'buying_and_selling'" do
    it "should be successful" do
      get 'buying_and_selling'
      response.should be_success
    end
  end

  describe "GET 'offers'" do
    it "should be successful" do
      get 'offers'
      response.should be_success
    end
  end

end
