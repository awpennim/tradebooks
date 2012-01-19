class ListingsController < ApplicationController
  before_filter :set_listing, :except => [:for_sale, :looking_for, :post_for_sale, :post_looking_for, :create]
  before_filter :set_textbook
  before_filter :authenticate, :except => [:for_sale, :looking_for]

  def why_renew
    @title = "Why Renew?"
  end

  def for_sale
    @title = "For Sale : #{ @textbook.title }"
    @listings = @textbook.sell_listings.paginate(:page => params[:page])
  end

  def looking_for
    @title = "Looking For: #{ @textbook.title }"
    @listings = @textbook.buy_listings.paginate(:page => params[:page])
  end

  def new_selling_offer
    redirect_to textbook_listing_path(@textbook, @listing), :notice => "You've already sent #{@listing.poster.username} an offer for this book. You can check your offers sent by navigating to the 'Offers' page in the upper-left links then clicking 'View sent offers here'" if current_user.active_offer_sent_to_user_for_textbook(@listing.poster.id, @textbook.id) 

    @title = "Sales Offer to #{@listing.poster.username}"
    @other_user = @listing.poster
    @offer = Offer.new
  end

  def new_buying_offer
    redirect_to textbook_listing_path(@textbook, @listing), :notice => "You've already sent #{@listing.poster.username} an offer for this book. You can check your offers sent by navigating to the 'Offers' page in the upper-left links then clicking 'View sent offers here'" if current_user.active_offer_sent_to_user_for_textbook(@listing.poster.id, @textbook.id) 

    @title = "Purchase Offer to #{@listing.poster.username}"
    @other_user = @listing.poster
    @offer = Offer.new
  end

  def show
    if @listing.nil?
      redirect_to root_path 
      return
    end

    @offer = current_user.active_offer_sent_to_user_for_textbook @listing.poster.id, @textbook.id

    if @selling	
      @title = "'For Sale' Listing for: #{@listing.textbook.title_short}"
    else
      @title = "'Looking For' Listing for: #{@listing.textbook.title_short}"
    end
  end

  def edit
   if @selling
     @title = "Edit 'For Sale' listing for: #{@textbook.title}"
   else
     @title = "Edit 'Looking For' listing for: #{@textbook.title}"
   end
  end

  def post_for_sale
    @listing = Listing.new
    @title = "Post your 'For Sale' listing for #{@textbook.title}"
  end

  def post_looking_for
    @listing = Listing.new
    @title = "Post your 'Looking For' listing for #{@textbook.title}"
  end

  def create
    params[:listing][:price].gsub!('$','')

    if params[:selling] == "true"
      @listing = current_user.sell_listings.build(params[:listing].merge(:textbook_id => @textbook.id, :selling => true))
    else
      @listing = current_user.buy_listings.build(params[:listing].merge(:textbook_id => @textbook.id, :selling => false))
    end

    if @listing.save
      Listing.increase_count
      if @listing.selling?
        redirect_to textbook_listing_path(@textbook, @listing), :notice => "You've listed #{@textbook.title} 'For Sale'"
      else
        redirect_to textbook_listing_path(@textbook, @listing), :notice => "You've listed #{@textbook.title} 'Looking For'"
      end
    else
      if params[:selling] == "true"
        render :post_for_sale
      else
        render :post_looking_for
      end
    end
  end

  def renew
    @listing = Listing.find_by_id(params[:id])
    @listing.renew!

    redirect_to textbook_listing_path(@textbook, @listing), :notice => "Your listing has been renewed!"
  end

  def update
    params[:listing][:price].gsub!('$','')

    if @listing.update_attributes(:price => params[:listing][:price])
      redirect_to textbook_listing_path(@textbook, @listing), :notice => "You updated your Asking Price for your #{@textbook.title} listing!"
    else
      render :edit
    end
  end

  def destroy
    @listing.destroy

    redirect_to @textbook, :notice => "You've removed your 'For Sale' listing for #{@textbook.title}"
  end

  private

    def set_listing
      @listing = Listing.find_by_id(params[:id])
      redirect_to root_path, :notice => "We couldn't find a listing with that ID" if @listing.nil?
      @selling = @listing.selling?
    end

    def set_textbook
      @textbook = Textbook.find_by_id(params[:textbook_id])
    end
end
