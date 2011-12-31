require "spec_helper"

describe TextbooksController do
  describe "routing" do

    it "routes to #index" do
      get("/textbooks").should route_to("textbooks#index")
    end

    it "routes to #new" do
      get("/textbooks/new").should route_to("textbooks#new")
    end

    it "routes to #show" do
      get("/textbooks/1").should route_to("textbooks#show", :id => "1")
    end

    it "routes to #edit" do
      get("/textbooks/1/edit").should route_to("textbooks#edit", :id => "1")
    end

    it "routes to #create" do
      post("/textbooks").should route_to("textbooks#create")
    end

    it "routes to #update" do
      put("/textbooks/1").should route_to("textbooks#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/textbooks/1").should route_to("textbooks#destroy", :id => "1")
    end

  end
end
