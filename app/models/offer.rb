class Offer < ActiveRecord::Base
  attr_accessible :reciever_id, :textbook_id, :selling, :message, :price, :counter
  attr_accessor :counter

  belongs_to :sender, :class_name => "User"
  belongs_to :reciever, :class_name => "User"
  belongs_to :textbook

  validates :sender_id, :presence => true
  validates :reciever_id, :presence => true
  validates :message, :length => {:maximum => 200, :message => "Message must be 200 characters or less"}
  validates :price, :numericality => {:greater_than => 0.0, :less_than => 300.0, :message => "The Offer Amount must be between $299.99 and $0.01"}
  validates :textbook_id, :presence => true

  STATUS_LIST = ["Active", "Rejected", "Counter Offer Sent", "Cancelled: Interested seller sold the book to another buyer", "Cancelled: Interested buyer bought the same book from another seller", "Cancelled: Interested buyer's account was deleted", "Cancelled: Interested seller's account was deleted", "Cancelled: Interested seller cancelled offer", "Cancelled: Interested buyer cancelled offer", "Accepted, Deal Made"]

  before_validation :check_textbook_id_and_reciever_id
  before_create :make_sure_no_duplicate_offers

  def update_status(new_status)
    return nil unless (0..(STATUS_LIST.length - 1)).include? new_status
    self.update_attribute('status', new_status)  if status == 0

    deal_with_other_offers if new_status == 9
  end

  def self.status_from_index(index)
    STATUS_LIST[index]
  end

  def active?
    self.status == 0
  end

  def listing
    if selling?
      sender.listing_from_textbook(textbook_id)
    else
      reciever.listing_from_textbook(textbook_id)
    end
  end

  def make_deal!
    return true if deal_with_other_offers 
  end

  private

    def check_textbook_id_and_reciever_id
      return false if Textbook.find_by_id(self.textbook_id).nil? || User.find_by_id(self.reciever_id).nil?
      return true
    end

    def make_sure_no_duplicate_offers
      other_offer = self.sender.offers_for_textbook_with_user(self.textbook_id, self.reciever_id).first

      return true if other_offer.nil? || other_offer.active? == false

      if self.reciever_id == other_offer.reciever_id
        self.errors.add(:reciever_id, "You already sent #{self.reciever.username} an offer for this book. You can check your offers sent by navigating to the 'Offers' page in the upper-left links then clicking 'View sent offers here'. (note: once a user rejects (not counter offers) your offer for a particular book, you may only respond to their offers)")
        return false
      elsif self.counter && self.reciever_id == other_offer.sender_id
        other_offer.update_status(2)
        return true
      else
        self.errors.add(:reciever_id, "You must respond to #{self.reciever.username}'s offer for this textbook first!")
      end
    end

    def deal_with_other_offers
      if self.selling?
        if self.sender.nil? == false
          self.sender.active_offers_for_textbook(self.textbook_id).each do |offer|
            offer.update_status(3)

            if self.sender_id == offer.sender_id
              offer.reciever.notify("#{self.sender.username} sold their copy of #{self.textbook.title_short} to another buyer")
	    else
              offer.sender.notify("#{self.sender.username} sold their copy of #{self.textbook.title_short} to another buyer")
	    end
	  end
        end
	if self.reciever.nil? == false
	  self.reciever.active_offers_for_textbook(self.textbook_id).each do |offer|
	    offer.update_status(4)

            if self.sender_id == offer.sender_id
              offer.reciever.notify("#{self.reciever.username} bought a copy of #{self.textbook.title_short} from another seller")
	    else
              offer.sender.notify("#{self.reciever.username} bought a copy of #{self.textbook.title_short} from another seller")
	    end
	  end
	end
      else
        if self.sender.nil? == false
          self.sender.active_offers_for_textbook(self.textbook_id).each do |offer|
            offer.update_status(4)

            if self.sender_id == offer.sender_id
              offer.reciever.notify("#{self.sender.username} bought a copy of #{self.textbook.title_short} from another seller")
	    else
              offer.sender.notify("#{self.sender.username} bought a copy of #{self.textbook.title_short} from another seller")
	    end
	  end
	end
	if self.reciever.nil? == false
	  self.reciever.active_offers_for_textbook(self.textbook_id).each do |offer|
	    offer.update_status(3)

            if self.sender_id == offer.sender_id
              offer.reciever.notify("#{self.sender.username} sold their copy of #{self.textbook.title_short} to another buyer")
	    else
              offer.sender.notify("#{self.sender.username} sold their copy of #{self.textbook.title_short} to another buyer")
	    end
	  end
	end
      end
    end
end
