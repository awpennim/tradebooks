class SellListingsController < ApplicationController
  before_filter :set_textbook

  def index
    @title = "For Sale : #{@textbook.title}"
    @listings = @textbook.sell_listings.paginate(:page => params[:page])
  end

  def show
    @listing = Listing.find_by_id(params[:id])

    if @listing.nil? || @listing.selling? == false
      redirect_to root_path 
      return
    end

    @title = "#{@listing.poster.username}'s 'For Sale' Listing for: #{@listing.textbook.title}"
  end

  def edit
    @listing = Listing.find_by_id(params[:id])
    redirect_to root_path if @listing.nil? || @listing.selling? == false
    @title = "Edit 'For Sale' listing for: #{@listing.textbook.title}"
  end

  def new
    @listing = Listing.new
    @title = "Post your copy of #{@textbook.title}"
  end

  def create
    @listing = current_user.sell_listings.build(params[:listing].merge(:textbook_id => @textbook.id, :selling => true))

    if @listing.save
      redirect_to textbook_sell_listing_path(@textbook, @listing), :notice => "You've listed #{@textbook.title}"
    else
      render :new
    end
  end

  def renew
    @listing = Listing.find_by_id(params[:id])
    @listing.renew!

    redirect_to textbook_sell_listing_path(@textbook, @listing), :notice => "Your listing has been renewed!"
  end

  def update

  end

  def destroy
    @listing = Listing.find_by_id(params[:id])
    @listing.destroy

    redirect_to @textbook, :notice => "You've removed your 'For Sale' listing for #{@textbook.title}"
  end

  private

    def set_textbook
      @textbook = Textbook.find_by_id(params[:textbook_id])
    end
end
