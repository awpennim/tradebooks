class Offer < ActiveRecord::Base
  attr_accessible :reciever_id, :textbook_id, :selling, :price, :offer, :message
  attr_accessor :counter

  belongs_to :sender, :class_name => "User"
  belongs_to :reciever, :class_name => "User"
  belongs_to :textbook

  validates :sender_id, :presence => true
  validates :reciever_id, :presence => true
  validates :message, :length => {:maximum => 250, :message => "Message must be 250 characters or less"}
  validates :price, :numericality => {:greater_than => 0.0, :less_than => 300.0, :message => "The Offer Amount must be between $299.99 and $0.01"}
  validates :textbook_id, :presence => true

  #Double array. The first array is an array of strings containing a description of the status from the buyer's point of view. The second array is an array of strings containing a description of the status from the seller's point of view.
  STATUS_LIST = [["Active", "Rejected", "Counter Offer Sent", "Cancelled: Interested seller sold the book to another buyer", "Cancelled: Interested buyer bought the same book from another seller", "Cancelled: Interested buyer's account was deleted", "Cancelled: Interested seller's account was deleted", "Cancelled: Interested seller cancelled offer", "Cancelled: Interested buyer cancelled offer", "Deal Made (Check Your 'Deals')", "Expired", "Seller removed 'For Sale' listing"],["Active", "Rejected", "Counter Offer Sent", "Cancelled: Interested seller sold the book to another buyer", "Cancelled: You purchased the same book from another seller", "Cancelled: Your account was deleted", "Cancelled: Interested seller's account was deleted", "Cancelled: Interested seller cancelled offer", "Cancelled: You cancelled the offer", "Deal Made, Book Purchased (Check Your 'Deals')", "Expired", "Cancelled: Seller removed 'For sale' listing"], ["Active", "Rejected", "Counter Offer Sent", "Cancelled: You sold the book to another buyer", "Cancelled: Interested buyer bought the same book from another seller", "Cancelled: Interested buyer's account was deleted", "Cancelled: Your account was deleted", "Cancelled: You cancelled the offer", "Cancelled: Interested buyer cancelled offer", "Deal Made, Book Sold (Check Your 'Deals')", "Expired", "You removed the 'For Sale' listing for this book"]]

  before_validation :check_textbook_id_and_reciever_id
  before_create :make_sure_no_duplicate_offers

  def update_status(new_status)
    return nil unless (0..(STATUS_LIST[0].length - 1)).include? new_status

    self.update_attribute('status', new_status)  if status == 0 #if the offer is still active, update it to the new status

    make_deal! if new_status == 9 #if new status is to make a new deal, then make a new deal
  end

  #returns a string of the current status from either the buyer or the sellers perspective
  def self.status_from_index(index, options = {})
    return STATUS_LIST[1][index] if options[:buying]
    return STATUS_LIST[2][index] if options[:selling]
    STATUS_LIST[0][index]
  end

  def active?
    self.status == 0
  end

  #returns the listing of the book that the offer is dealing with
  def listing
    if selling?
      sender.selling_listing_from_textbook(textbook_id)
    else
      reciever.selling_listing_from_textbook(textbook_id)
    end
  end

  #checks to make sure the offer has not expired. This method is called whenever the offer is accessed from the database.
  def check_status!
    if (created_at + 48.hours).past?
      update_status(10)
      return false
    end
    return true

  end

  #this method creates a new Deal from the current offer.
  def make_deal!
    if deal_with_other_offers 
      if selling?
        Deal.create!(:buyer_id => self.reciever_id, :seller_id => self.sender_id, :price => self.price, :textbook_id => self.textbook_id, :description => self.listing.description)
      else
        Deal.create!(:buyer_id => self.sender_id, :seller_id => self.reciever_id, :price => self.price, :textbook_id => self.textbook_id, :description => self.listing.description)
      end

      sender_listing = sender.listing_from_textbook(textbook_id)
      sender_listing.destroy if sender_listing.nil? == false

      reciever_listing = reciever.listing_from_textbook(textbook_id)
      reciever_listing.destroy if reciever_listing.nil? == false
    else
      return false
    end
  end

  private

    #makes sure the textbook id and reciever id exist
    def check_textbook_id_and_reciever_id
      return false if Textbook.find_by_id(self.textbook_id).nil? || User.find_by_id(self.reciever_id).nil?

      if reciever_id === sender_id
        self.errors.add(:reciever_id, "You can't send an offer to yourself!")
	return false
      end

      if self.sender.listing_from_textbook(self.textbook_id) && self.sender.listing_from_textbook(self.textbook_id).selling? != self.selling?
        if self.selling?	
          self.errors.add(:reciever_id, "You're currently listing this book 'Looking For' not 'For Sale'. You must list this book 'For Sale' before sending selling offers for it")
	  return false
	  else
          self.errors.add(:reciever_id, "You're currently listing this book 'For Sale'. You must remove that listing before sending offers to other users to buy theirs")
	  return false

	  end
      end

      return true
    end

    #makes sure this is the only active offer between two users for a specific textbook.
    def make_sure_no_duplicate_offers
      other_offer = self.sender.active_offer_between_user_for_textbook(self.reciever_id, self.textbook_id)

      if other_offer.nil?
        if self.listing.nil?
	  if self.selling?
            self.errors.add(:reciever_id, "You don't have a current listing 'For Sale' for this book. You must post a listing before sending an offer to sell your book.")
	  else
            self.errors.add(:reciever_id, "#{self.reciever.username} doesn't have a current listing 'For Sale' for this book.")
	  end

          return false
	end
          
        return true
      end

      if self.reciever_id == other_offer.reciever_id
        self.errors.add(:reciever_id, "You already sent #{self.reciever.username} an offer for this book. You can check your offers sent by navigating to the 'Offers' page in the upper-left links then clicking 'View sent offers here'. (note: once a user rejects (not counter offers) your offer for a particular book, you may only respond to their offers)")
        return false
      elsif other_offer.selling? != self.selling?
        other_offer.update_status(2)
        return true
      else
        self.errors.add(:reciever_id, "#{self.reciever.username}'s removed their listing for this book!")
      end
    end

    #When a deal is made, all other offers sent or recieved to/from either the seller or buyer are automatically cancelled to let other potential buyers know the book has been sold or let other potential sellers know that the user bought the book from someone else. It also cancels all other offers concerning this specific book so duplicate deals are avoided.
    def deal_with_other_offers
      if self.selling?
        if self.sender.nil? == false
          self.sender.active_offers_for_textbook(self.textbook_id).each do |offer|
            offer.update_status(3)

            if self.sender_id == offer.sender_id
	      Offer.notify_buyer_book_sold(offer.reciever,offer.sender,textbook)
	    else
	      Offer.notify_buyer_book_sold(offer.sender,offer.reciever,textbook)
	    end
	  end
        end
	if self.reciever.nil? == false
	  self.reciever.active_offers_for_textbook(self.textbook_id).each do |offer|
	    offer.update_status(4)

            if self.sender_id == offer.sender_id
	      Offer.notify_seller_book_bought(offer.reciever,offer.sender,textbook)
	    else
	      Offer.notify_seller_book_bought(offer.sender, offer.reciever, textbook)
	    end
	  end
	end
      else
        if self.sender.nil? == false
          self.sender.active_offers_for_textbook(self.textbook_id).each do |offer|
            offer.update_status(4)

            if self.sender_id == offer.sender_id
	      Offer.notify_seller_book_bought(offer.reciever, offer.sender, textbook)
	    else
	      Offer.notify_seller_book_bought(offer.sender, offer.reciever, textbook)
	    end
	  end
	end
	if self.reciever.nil? == false
	  self.reciever.active_offers_for_textbook(self.textbook_id).each do |offer|
	    offer.update_status(3)

            if self.sender_id == offer.sender_id
              Offer.notify_buyer_book_sold(offer.reciever, offer.sender, textbook)
	    else
              Offer.notify_buyer_book_sold(offer.sender, offer.reciever, textbook)
	    end
	  end
	end
      end
    end

    #double checks that the book is 'For Sale' before sending an offer to buy it, or before sending a sales offer to another user.
    def check_book_is_listed
      if selling?
        listing = sender.listing_from_textbook(textbook_id)

	if listing.nil?
          self.errors.add(:sender_id, "You must list this book 'For Sale' before sending an offer to sell it!")
	  return false
	end
      else
        listing = reciever.listing_from_textbook(textbook_id)

        if listing.nil?
          self.errors.add(:reciever_id, "#{self.reciever.username} must list this book 'For Sale' before sending an offer to buy it!")
	end
      end
    end

    #These next methods deal with delivering notifications

    #Deal made, notify seller that their book has been sold
    def self.deal_notify_seller(user, other_user , offer)
      user.notify("<b>Congratulations!</b> Your offer to #{ActionController::Base.helpers.link_to(other_user.username, Rails.application.routes.url_helpers.user_path(other_user))} to <b>sell</b> your copy of #{ ActionController::Base.helpers.link_to(offer.textbook.title_short,  Rails.application.routes.url_helpers.textbook_path(offer.textbook))} for <b>#{   ActionController::Base.helpers.number_to_currency(offer.price) } has been accepted!</b> Please communicate with #{ ActionController::Base.helpers.link_to(other_user.username, Rails.application.routes.url_helpers.user_path(other_user))} through the #{ ActionController::Base.helpers.link_to('Deals', Rails.application.routes.url_helpers.active_deals_user_path(user))} link to organize the trade.")
    end

    #Deal made, notify buyer that they have purchased a book
    def self.deal_notify_buyer(user, other_user , offer)
      user.notify("<b>Congratulations!</b> Your offer to #{ActionController::Base.helpers.link_to(other_user.username, Rails.application.routes.url_helpers.user_path(other_user))} to <b>buy</b> their copy of #{ ActionController::Base.helpers.link_to(offer.textbook.title_short, Rails.application.routes.url_helpers.textbook_path(offer.textbook))} for <b> #{ ActionController::Base.helpers.number_to_currency(offer.price) } has been accepted!</b> Please communicate with #{ ActionController::Base.helpers.link_to(other_user.username, Rails.application.routes.url_helpers.user_path(other_user))} through the #{ ActionController::Base.helpers.link_to('Deals', Rails.application.routes.url_helpers.active_deals_user_path(user))} link to organize the trade.")
    end

    #Notify buyer that their purchase offer was rejected
    def self.purchase_offer_rejected(user, other_user, textbook)
      user.notify("Sorry, #{ActionController::Base.helpers.link_to(other_user.username, Rails.application.routes.url_helpers.user_path(other_user))} <b>rejected your purchase offer</b> for #{ ActionController::Base.helpers.link_to(textbook.title_short, Rails.application.routes.url_helpers.textbook_path(textbook))}")
    end

    #Notify seller that their sales offer was rejected
    def self.sales_offer_rejected(user, other_user, textbook)
      user.notify("Sorry, #{ActionController::Base.helpers.link_to(other_user.username, Rails.application.routes.url_helpers.user_path(other_user))} <b>rejected your purchase offer</b> for #{ ActionController::Base.helpers.link_to(textbook.title_short, Rails.application.routes.url_helpers.textbook_path(textbook))}")
    end
  
    #Notify potential buyer that the book they sent an offer for was sold to another user
    def self.notify_buyer_book_sold(user, other_user, textbook)
      user.notify("Sorry, #{ActionController::Base.helpers.link_to(other_user.username, Rails.application.routes.url_helpers.user_path(other_user))} <b>sold their copy</b> of #{ ActionController::Base.helpers.link_to(textbook.title_short, Rails.application.routes.url_helpers.textbook_path(textbook))} to <b>a different buyer</b>")
    end

    #Notify potential seller that the user they sent a sales offer to for a specify book, bought that book from a different seller.
    def self.notify_seller_book_bought(user, other_user, textbook)
      user.notify("Sorry, #{ActionController::Base.helpers.link_to(other_user.username, Rails.application.routes.url_helpers.user_path(other_user))} <b>bought a copy</b> of #{ ActionController::Base.helpers.link_to(textbook.title_short, Rails.application.routes.url_helpers.textbook_path(textbook))} from <b>a different seller</b>")
    end
end
