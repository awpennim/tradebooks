class Message < ActiveRecord::Base
  attr_accessor :reciever_username
  attr_accessible :reciever_username, :text

  belongs_to :sender, :class_name => "User"
  belongs_to :reciever, :class_name => "User"

  validates :sender_id, :presence => true
  validates :reciever_id, :presence => true
  validates :text, :presence => true

  before_validation :check_users_existance

  def approved_user?(user)

    return false if user.id != self.sender_id && user.id != self.reciever_id && user.admin? == false
    return true
  end

  def correct_sending_user?(user)
    return false if user.id != self.sender_id
  end

  def correct_recieving_user?(user)
    return false if user.id != self.reciever_id
  end

  def mark_read!
    self.toggle!(:read) unless self.read?
  end

  private

  def check_users_existance
    puts "CHECKING!!!!!!!!!"

    if User.find_by_id(self.sender_id).nil? || User.find_by_username(self.reciever_username).nil?
      self.errors.add(:reciever_username, "The person you're trying to send to doesn't exist")	
      return false
    else
      self.reciever_id = User.find_by_username(self.reciever_username).id
      return true
    end
  end
end
