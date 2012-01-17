class Faq < ActiveRecord::Base
  attr_accessible :question, :answer

  validates :user_id, :presence => true
  validates :answer, :presence => {:message => "You left the answer blank!"},
                     :length => {:within => 0..1000, :message => "Answer can't be more than 1000 characters"}
  validates :question, :presence => {:message => "You left the question blank!"},
                       :length => {:within => 0..255, :message => "Question must be under 256 characters"}

  before_validation :user_is_admin

  belongs_to :user

  private
  
    def user_is_admin
      User.find_by_id(user_id).admin?
    end
end
