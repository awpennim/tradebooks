class Deal < ActiveRecord::Base
  attr_accessible :buyer_id, :seller_id, :price, :textbook_id, :description

  validates :buyer_id, :presence => true
  validates :seller_id, :presence => true
  validates :price, :numericality => {:within => (0.00)..(300.00)}
  validates :textbook_id, :presence => true

  belongs_to :buyer, :class_name => "User"
  belongs_to :seller, :class_name => "User"
  belongs_to :textbook
end
