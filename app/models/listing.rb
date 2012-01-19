class Listing < ActiveRecord::Base
  @@cache = {}
  @@lock = Mutex.new

  attr_accessible :price, :textbook_id, :selling, :description

  belongs_to :poster, :class_name => "User", :foreign_key => 'user_id'
  belongs_to :textbook

  scope :recent_for_sale, where(:selling => true).order('updated_at DESC')
  scope :recent_looking_for, where(:selling => false).order('updated_at DESC')

  validates :price, :numericality => {:greater_than => 0.0, :less_than => 300.0, :message => "You must enter a price between $300 and $0 (exclusive)"}
  validates :user_id, :presence => {:message => "You must be signed in!"},
                      :uniqueness => {:scope => [:textbook_id ], :message => "You are only allowed one listing per book. However, you may edit your book or click 'renew' (accessing it through 'Listings' or 'Looking For' in the upper left header) to move it to the top of the list."}
  validates :textbook_id, :presence => {:message => "Database error!"}
  validates :description, :length => {:within => 0..250, :message => "Description can't be over 250 characters"}

  before_validation :check_textbook_id

  before_destroy :remove_offers
  before_destroy :decrease_count_instance_method

  def self.total
    return @@cache[:total] if @@cache[:total]
 
    get_count! 
  end

  def self.increase_count
    get_count! if @@cache[:total].nil?

    @@lock.synchronize do
      @@cache[:total] = @@cache[:total] + 1
    end
  end

  def self.decrease_count
    get_count! if @@cache[:total].nil?

    @@lock.synchronize do
      @@cache[:total] = @@cache[:total] - 1
    end
  end

  def id_long
    ("0" * (8 - self.id.to_s.length)).to_s + self.id.to_s
  end

  def renew!
    self.touch
  end

  def has_description?
    description.blank? == false
  end

  def description_short
    if description.length > 40
      description[0..37] + "..."
    elsif description.blank?
      id_long
    else
      description
    end
  end

  private

    def check_textbook_id
      Textbook.find_by_id(textbook_id).nil? == false
    end

    def remove_offers
      return true if self.selling? == false

      poster.active_offers_for_textbook(textbook_id).each do |done|
        if
          done.update_status(11)
	end
      end
    end

    def self.get_count!
      num = self.count

      @@lock.synchronize do
        @@cache[:total] = num
      end

      num
    end

    def decrease_count_instance_method
      Listing.decrease_count
    end
end
