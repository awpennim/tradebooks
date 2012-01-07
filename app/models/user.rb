class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation, :current_password
  attr_accessible :email, :password, :password_confirmation, :current_password

  EMAIL_REGEX = /\A[\w+\-.]+@student\.umass\.edu/i

  validates :email, :presence => {:message => "Email field is blank"},
                    :format => {:with => EMAIL_REGEX},
		    :uniqueness => {:case_sensitive => false}
  validates :password, :presence => true,
                       :confirmation => true,
		       :length => {:within => 6..30}

  
  before_validation :validate_current_password, :if => :old_record?
  before_save :encrypt_password

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


  private
    def old_record?
      !new_record?
    end

    def validate_current_password
      unless has_password? current_password
        self.errors.add(:current_password, "is incorrect")
        return false
      end

      return true
    end

    def encrypt_password
      return if password == nil
      self.salt = make_salt unless has_password?(password)
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
