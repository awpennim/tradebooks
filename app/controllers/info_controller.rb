class InfoController < ApplicationController
  skip_before_filter :ensure_verified

  def home
    @title = "Welcome"
  end

  def contact
    @title = "Contact"
  end

  def about
    @title = "About"
  end

  def faq
    @title = "Frequently Asked Questions"
  end

end
