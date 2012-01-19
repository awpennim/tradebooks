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
    @faqs = Faq.paginate(:page => params[:page], :per_page => 5, :order => 'created_at DESC')
  end

  def privacy_policy
    @title = "Privacy Policy"
  end

  def under_construction
    @title = "Under Construction Page"
  end

  def recent_for_sale

  end

  def recent_looking_for

  end
end
