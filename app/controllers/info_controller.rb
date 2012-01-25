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

  def spire
    @title = "Finding ISBNs with SPIRE"
  end

  def signing_up
    @title = "How to set up your TradeCampusBooks account"
  end

  def list_book_for_sale
    @title = "How to list a book 'For Sale'"
  end

  def list_book_looking_for
    @title = "How to list a book 'Looking For'"
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
    @title = "Recent 'For Sale' Listings"
    @listings = Listing.recent_for_sale.paginate(:page => params[:page], :per_page => 15)
  end

  def recent_looking_for
    @title = "Recent 'Looking For' Listings"
    @listings = Listing.recent_looking_for.paginate(:page => params[:page], :per_page => 15)
  end
end
