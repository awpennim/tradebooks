class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :reciever, :class_name => "User"

  validates :sender_id, :presence => true
  validates :reciever_id, :presence => true
  validates :text, :presence => true
end
