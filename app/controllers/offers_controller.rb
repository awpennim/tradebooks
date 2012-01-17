class OffersController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_filter :set_offer, :except => [:new_selling, :new_buying, :create]
  before_filter :set_textbook
  before_filter :authenticate

  def counter
    @listing = @offer.listing
    @counter = true

    if @offer.selling?
      @offer = Offer.new
      render 'listings/new_buying_offer'
    else
      @offer = Offer.new
      render 'listings/new_selling_offer'
    end
  end

  def accept
    @offer.update_status(9)
    @offer.make_deal!
    if @offer.selling?
      @offer.sender.notify("Your offer to #{@offer.reciever.username} to sell your copy of #{@offer.textbook.title_short} for #{ number_to_currency(@offer.price) } has been accepted! Please communicate with #{ @offer.reciever.username } through the 'Deals' link to organize the trade.")
      redirect_to recieved_offers_user_path(current_user), :notice => "Congratulations! You've accepted to sell #{@offer.sender.username} your copy of #{@offer.textbook.title_short} for #{@offer.price}"
    else
      @offer.sender.notify("Your offer to #{@offer.reciever.username} to buy #{@offer.textbook.title_short} for #{ number_to_currency(@offer.price) } has been accepted! Please communicate with #{ @offer.reciever.username } through the 'Deals' link to organize the trade.")
      redirect_to recieved_offers_user_path(current_user), :notice => "Congratulations! You've accepted to buy #{@offer.sender.username}'s copy of #{@offer.textbook.title_short} for #{@offer.price}"
    end
  end

  def reject
    @offer.update_status(1)
    @offer.sender.notify("Your offer to #{@offer.reciever.username} for #{@offer.textbook.title_short} was rejected")
    redirect_to sent_offers_user_path(current_user), :notice => "You've rejected #{@offer.reciever.username}'s offer for #{@offer.textbook.title_short}"
  end

  def cancel
    if @offer.selling?
      @offer.update_status(7)
      redirect_to params[:path], :notice => "You've cancelled your selling offer to #{@offer.reciever.username} for #{@offer.textbook.title_short}"
    else
      @offer.update_status(8)
      redirect_to params[:path], :notice => "You've cancelled your buying offer to #{@offer.reciever.username} for #{@offer.textbook.title_short}"
    end
  end

  def create
    params[:offer][:message] = nil if params[:offer][:message].blank?

    @offer = current_user.sent_offers.build(params[:offer].merge(:counter => false)) 
    @listing = Listing.find_by_id(params[:offer][:listing_id])

    if @offer.save
      redirect_to @textbook, :notice => "You've sent an offer to #{@listing.poster.username} to buy #{@textbook.title_short} for #{number_to_currency @offer.price}. #{@listing.poster.username} has 24 hours to respond to your offer."
    else
      @title = "Buy #{@listing.poster.username}'s #{@textbook.title_short}"
      render 'listings/new_buying_offer',     
    end

  end

  private

    def set_offer
      @offer = Offer.find_by_id(params[:id])
    end

    def set_textbook
      @textbook = Textbook.find_by_id(params[:textbook_id])
    end
end
