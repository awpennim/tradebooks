require 'spec_helper'

describe InfoController do
  render_views

  before(:each) do
    @base_title = "Zoomass Textbooks | "
  end

  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end

    it "should have proper title" do
      get 'home'
      response.should have_selector("title", :content => @base_title + "Welcome")
    end
  end

  describe "GET 'contact'" do
    it "should be successful" do
      get 'contact'
      response.should be_success
    end

    it "should have proper title" do
      get 'contact'
      response.should have_selector("title", :content => @base_title + "Contact")
    end
  end

  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end

    it "should have proper title" do
      get 'about'
      response.should have_selector("title", :content => @base_title + "About")
    end
  end
end
