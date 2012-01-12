class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation, :current_password
  attr_accessible :email, :password, :password_confirmation, :current_password, :location

  EMAIL_REGEX = /\A[\w+\-.]+@student\.umass\.edu/i

  LOCATIONS_LIST = ["(Not Specified)", "Off-Campus Housing", "Commuter", "Baker Hall, Central" "Brett Hall, Central", "Brooks Hall, Central", "Brown Hall, Sylvan","Butterfield Hall, Central", "Cance Hall, Southwest", "Cashin Hall, Sylvan", "Chadbourne Hall, Central", "Coolidge Hall, Southwest", "Crabtree Hall, Northeast", "Crampton Hall, Southwest", "Dickinson Hall, Orchard Hill", "Dwight Hall, Northeast", "Emerson Hall, Southwest", "Field Hall, Orchard Hill", "Gorman Hall, Central", "Grayson Hall, Orchard Hill", "Greenough Hall, Central", "Hamlin Hall, Northeast", "James Hall, Southwest", "John Adams Hall, Southwest", "John Quincy Adams Hall, Southwest", "Johnson Hall, Northeast", "Kennedy Hall, Southwest", "Knowlton Hall, Northeast", "Leach Hall, Northeast", "Lewis Hall, Northeast", "MacKimmie Hall, Southwest", "Mary Lyon Hall, Northeast", "McNamara hall, Sylvan", "Melville Hall, Southwest", "Moore Hall, Southwest", "North A, North", "North B, North", "North C, North", "North D, North", "Patterson Hall, Southwest", "Pierpont Hall, Southwest", "Prince Hall, Southwest", "Thatcher Hall, Northeast", "Thoreau Hall, Southwest", "Van Meter Hall, Central", "Washington Hall, Southwest", "Webster Hall, Orchard Hill", "Wheeler Hall, Central"]

  validates :email, :presence => {:message => "Email field is blank"},
                    :format => {:with => EMAIL_REGEX, :message => "Make sure your email ends with '@student.umass.edu'"},
		    :uniqueness => {:case_sensitive => false, :message => "You've already registered <br/> Follow the link below to login"}
  validates :password, :presence => {:message => "You left the password field blank!"},
                       :confirmation => {:message => "Your confirmation didn't match your password"},
		       :length => {:within => 6..30, :message => "Your password must be between 6 and 30 characters"}
  validates :location, :presence => {:message => "You must select a Living Location"},
                       :numericality => {:maximum => 46, :minimum => 0}

  before_validation :fill_passwords_fields_if_empty
  before_validation :encrypt_password
  after_create :make_verify_token

  has_many :notifications, :order => 'created_at DESC', :dependent => :delete_all
  has_many :sent_messages, :class_name => "Message", :foreign_key => "sender_id", :dependent => :delete_all, :order => 'created_at DESC'
  has_many :recieved_messages, :class_name => "Message", :foreign_key => "reciever_id", :dependent => :delete_all, :order => 'created_at DESC'

  has_many :sell_listings, :class_name => "Listing", :foreign_key => "user_id", :dependent => :delete_all, :order => 'created_at DESC', :conditions => { :selling => true }
  has_many :buy_listings, :class_name => "Listing", :foreign_key => "user_id", :dependent => :delete_all, :order => 'created_at DESC', :conditions => { :selling => false }

  def self.LOCATIONS_LIST_ARRAY
    LOCATIONS_LIST
  end

  def self.location_from_index(index)
    LOCATIONS_LIST[index]
  end

  def self.index_from_location(loc)
    LOCATIONS_LIST.index loc
  end

  def self.matching_locations(user1, user2)
    return false if user1.nil? || user2.nil? || user1.location != user2.location
    return true
  end

  def location_str
    User.location_from_index(self.location)
  end

  def new_notifications
    Notification.where(:user_id => self.id, :read => false)
  end

  def new_messages
    Message.where(:reciever_id => self, :read => false)
  end

  def has_password?(value)
    self.encrypted_password == encrypt(value)
  end

  def self.authenticate_with_salt(id, salt)
    return nil if id.nil? || salt.nil?
    
    user = User.find_by_id(id)

    return nil if user.nil?

    if user.salt == salt
      return user
    else
      return nil
    end
  end

  def self.authenticate(email, password)
    return nil if email.nil? || password.nil?

    user = User.find_by_email(email)

    return nil if user.nil?

    return user if user.has_password?(password)
  end

  def username
    email[0..(email.index("@") - 1)]
  end

  def verify!(value)
    return false if value.nil?
    if value.to_s == self.verify_token
      self.toggle!(:verified) unless self.verified?
    end

    return true
  end

  def verified?
    self.verified
  end

  def make_verify_token
    User.update_all({:verify_token => Digest::SHA1.hexdigest("--#{Time.now.to_s}--")[0,20]}, :id => self.id)
    self.verify_token
  end

  def get_token
    self.verify_token
  end

  def notify(message)
    self.notifications.build(:message => message.to_s).save
  end

  def admin?
    self.admin == true
  end

  def self.find_by_username(username)
    find_by_email(username.to_s + "@student.umass.edu")
  end

  private
    def old_record?
      new_record? == false
    end

    def validate_password(value)
      unless has_password? value
        self.errors.add(:current_password, "Current Password is incorrect")
        return false
      end

      return true
    end

    def fill_passwords_fields_if_empty
      if old_record? && current_password.blank?
        self.errors.add(:password, "You must enter your current password to update your settings")
	return false
      end

      if old_record? && self.password.blank?
        self.password = current_password
	self.password_confirmation = current_password
      end
    end

    def encrypt_password
      return if has_password?(password)
      
      if old_record? && has_password?(current_password) == false#checks old password
        self.errors.add(:current_password, "The current password you enterered does not match our records")
	return false
      end

      self.salt = make_salt
      self.encrypted_password = encrypt(password)
    end

    def make_salt
      secure_hash("#{Time.now.utc}--+--#{password}")
    end

    def encrypt(string)
      secure_hash("#{salt}--+--#{string}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest string
    end
end
