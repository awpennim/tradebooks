class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation, :current_password
  attr_accessible :email, :password, :password_confirmation, :current_password

  EMAIL_REGEX = /\A[\w+\-.]+@student\.umass\.edu/i

  validates :email, :presence => {:message => "Email field is blank"},
                    :format => {:with => EMAIL_REGEX, :message => "Make sure your email ends with '@student.umass.edu'"},
		    :uniqueness => {:case_sensitive => false, :message => "You've already registered <br/> Follow the link below to login"}
  validates :password, :presence => {:message => "You left the password field blank!"},
                       :confirmation => {:message => "Your confirmation didn't match your password"},
		       :length => {:within => 6..30, :message => "Your password must be between 6 and 30 characters"}

  before_save :encrypt_password

  after_create :make_verify_token

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
    self.verified == true
  end

  def make_verify_token
    self.verify_token = Digest::SHA1.hexdigest("--#{Time.now.to_s}--")[0,20]
    save!
    self.verify_token
  end

  def get_token
    self.verify_token
  end

  private
    def old_record?
      puts new_record?
      new_record? == false
    end

    def validate_password(value)
      unless has_password? value
        self.errors.add(:current_password, "Current Password is incorrect")
        return false
      end

      return true
    end

    def encrypt_password
      return if password == nil || has_password?(password)

      if new_record? == false && !has_password?(current_password)#checks old password
        self.errors.add(:current_password, "The current password you enterered does not match our records")
	returns false
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
