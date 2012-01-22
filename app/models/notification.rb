class Notification < ActiveRecord::Base
  attr_accessible :message

  belongs_to :User

  validates :user_id, :presence => true
  validates :message, :presence => true

  def read?
    self.read == true
  end

  def mark_read
    self.toggle!(:read) unless self.read?
  end
end
