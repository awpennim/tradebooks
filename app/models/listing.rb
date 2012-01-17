class Listing < ActiveRecord::Base
  attr_accessible :price, :textbook_id, :selling

  belongs_to :poster, :class_name => "User", :foreign_key => 'user_id'
  belongs_to :textbook

  validates :price, :numericality => {:greater_than => 0.0, :less_than => 300.0, :message => "You must enter a price between $300 and $0 (exclusive)"}
  validates :user_id, :presence => {:message => "You must be signed in!"},
                      :uniqueness => {:scope => [:textbook_id ], :message => "You are only allowed one listing per book. However, you may edit your book or click 'renew' (accessing it through 'Listings' or 'Looking For' in the upper left header) to move it to the top of the list."}
  validates :textbook_id, :presence => {:message => "Database error!"}

  before_validation :check_textbook_id

  def id_long
    ("0" * (8 - self.id.to_s.length)).to_s + self.id.to_s
  end

  def renew!
    self.touch
  end

  private

    def check_textbook_id
      Textbook.find_by_id(textbook_id).nil? == false
    end
end
