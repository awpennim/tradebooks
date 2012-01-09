class Notification < ActiveRecord::Base
  belongs_to :User

  validates :message, :presence => true
  validates :user_id, :presence => true

  def read?
    self.read == true
  end

  def mark_read
    self.toggle!(:read) unless self.read?
  end
end
