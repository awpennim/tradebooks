class InfoController < ApplicationController
  def home
    @title = "Welcome"
  end

  def contact
    @title = "Contact"
  end

  def about
    @title = "About"
  end

end
