class Listing < ActiveRecord::Base
  attr_accessible :price, :textbook_id

  belongs_to :poster, :foreign_key => 'user_id'
  belongs_to :textbook

  validates :price, :presence => true,
                    :numericality => {:greater_than => 0, :less_than => 300}
  validates :user_id, :presence => true
  validates :textbook_id, :presence => true

  before_validation :check_textbook_id

  private

    def check_textbook_id
      Textbook.find_by_id(textbook_id).nil? == false
    end
end
