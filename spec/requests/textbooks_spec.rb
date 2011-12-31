require 'spec_helper'

describe "Textbooks" do
  describe "GET /textbooks" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get textbooks_path
      response.status.should be(200)
    end
  end
end
