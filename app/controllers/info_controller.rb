class InfoController < ApplicationController
  def home
    @title = "Welcome"
  end

  def contact
    @title = "Contact"
    Emailer.welcome_user(User.find_by_email("awpennim@student.umass.edu"))
  end

  def about
    @title = "About"
  end

  def faq
    @title = "FAQs"
  end

end
