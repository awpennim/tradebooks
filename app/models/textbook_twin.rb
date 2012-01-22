class TextbookTwin < ActiveRecord::Base
  belongs_to :textbook

  attr_accessible :isbn, :suffix

  validates :isbn, :presence => true
end
