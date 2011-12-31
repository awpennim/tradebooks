require 'spec_helper'

describe Textbook do

  before(:each) do
    @attr = {:isbn => "1234567890", :author => "author", :title => "fake title"}
  end

  it "should save valid" do
    text = Textbook.new(@attr)
    text.should be_valid
  end

  it "should not save ISBN too short" do
    text = Textbook.new(@attr.merge(:isbn => "123456789"))
    text.should be_valid
  end

  it "should not save ISBN too long" do
    text = Textbook.new(@attr.merge(:isbn => "12345678901"))
    text.should be_valid
  end

  it "should not save without a title" do
    Textbook.new(@attr.merge(:title => "")).should_not be_valid
  end

  it "should not save without an author" do
    Textbook.new(@attr.merge(:author => "")).should_not be_valid
  end
end

