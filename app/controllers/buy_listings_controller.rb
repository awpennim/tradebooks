class BuyListingsController < ApplicationController
  def index
    @textbook = Textbook.find_by_id(params[:textbook_id])
    @title = "Looking For : #{@textbook.title}"
    @listings = @textbook.buy_listings.paginate(:page => params[:page])
  end

  def new
    @title = ""
  end

  def show
    @listing = Listing.find_by_id(params[:id])
    @textbook = Textbook.find_by_id(params[:textbook_id])
    if @listing.nil? || @listing.selling? == true
      redirect_to root_path 
      return
    end

    @title = "#{@listing.poster.username}'s Buy Listing for: #{@listing.textbook.title}"
  end

  def edit
    @listing = Listing.find_by_id(:id)
    redirect_to root_path if @listing.nil? || @listing.selling?
    @title = "Edit buy listing for: #{@listing.textbook.title}"
  end

end
