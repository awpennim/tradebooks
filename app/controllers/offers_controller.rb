class OffersController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_filter :authenticate
  before_filter :set_offer, :except => [:new_selling, :new_buying, :create]
  before_filter :set_textbook
  before_filter :correct_user_reciever, :only => [:counter, :accept, :reject]
  before_filter :correct_user_sender, :only => [:cancel]
  before_filter :check_offer_expired

  def counter
    @listing = @offer.listing
    @counter_price = @offer.price
    @other_user = @offer.sender

    if @offer.selling? #Counter buying offer
      @title = "Counter Purchase Offer to #{@other_user.username}"
      @offer = Offer.new
      render 'listings/new_buying_offer'
    else #Counter selling offer
      @title = "Counter Sales Offer to #{@other_user.username}"
      @offer = Offer.new
      render 'listings/new_selling_offer'
    end
  end

  def accept
    @offer.update_status(9)

    if @offer.selling?
      Offer.deal_notify_seller(@offer.sender, @offer.reciever, @offer)
      UserMailer.deal_made_selling_notification(@offer).deliver
      redirect_to active_deals_user_path(current_user), :notice => "Congratulations! You've accepted to sell #{@offer.sender.username} your copy of #{@offer.textbook.title_short} for #{ number_to_currency @offer.price}"
    else
      Offer.deal_notify_buyer(@offer.sender, @offer.reciever, @offer)
      UserMailer.deal_made_buying_notification(@offer).deliver
      redirect_to active_deals_user_path(current_user), :notice => "Congratulations! You've accepted to buy #{@offer.sender.username}'s copy of #{@offer.textbook.title_short} for #{ number_to_currency @offer.price }"
    end
  end

  def reject
    @offer.update_status(1)
    if @offer.selling?
      Offer.sales_offer_rejected(@offer.sender, @offer.reciever, @offer.textbook)
      redirect_to active_recieved_offers_user_path(current_user), :notice => "You've rejected #{@offer.sender.username}'s sales offer for #{@offer.textbook.title_short}"
    else
      Offer.purchase_offer_rejected(@offer.sender, @offer.reciever, @offer.textbook)
      redirect_to active_recieved_offers_user_path(current_user), :notice => "You've rejected #{@offer.sender.username}'s purchase offer for #{@offer.textbook.title_short}"
    end
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

    @offer = current_user.sent_offers.build(params[:offer]) 
    @listing = Listing.find_by_id(params[:offer][:listing_id])

    if @offer.selling?
      if @offer.save
	UserMailer.sales_offer_recieved_notification(@offer.reciever, @offer).deliver
        redirect_to sent_offers_user_path(current_user), :notice => "Sales Offer sent to #{@offer.reciever.username} for '#{@textbook.title_short}' at #{number_to_currency @offer.price} #{@offer.receiver.username} has 48 hours to respond to your offer."
      else
	@other_user = @offer.reciever
        @counter_price = @other_user.active_offer_sent_to_user_for_textbook(@other_user.id, @textbook.id)
        @title = "To Sell '#{@textbook.title_short}' to #{@other_user.username}"
        render 'listings/new_selling_offer',     
      end
    else
      if @offer.save
        UserMailer.purchase_offer_recieved_notification(@offer.reciever, @offer).deliver
        redirect_to sent_offers_user_path(current_user), :notice => "Purchase Offer sent to #{@offer.reciever.username} for '#{@textbook.title_short}' at #{ number_to_currency @offer.price } #{@offer.reciever.username} has 48 hours to respond to your offer."
      else
        @other_user = @offer.reciever
        @counter_price = @other_user.active_offer_sent_to_user_for_textbook(@other_user.id, @textbook.id)
        @title = "To Buy '#{@textbook.title_short}' from #{@other_user.username}"
        render 'listings/new_buying_offer',     
      end
    end

  end

  private

    def set_offer
      @offer = Offer.find_by_id(params[:id])
    end

    def check_offer_expired
      if @offer.nil? == false
        @offer.check_status!

        if @offer.active? != true
           redirect_to active_recieved_offers_user_path(current_user), :notice => "That offer is no longer active"
          return
        end
      end
    end

    def set_textbook
      @textbook = Textbook.find_by_id(params[:textbook_id])
    end

    def correct_user_reciever
      redirect_to home_user_path(current_user), :notice => "You don't have permission to do that!" if @offer.reciever_id != current_user.id
    end

    def correct_user_sender
      redirect_to home_user_path(current_user), :notice => "You don't have permission to do that!" if @offer.sender_id != current_user.id
    end
end
