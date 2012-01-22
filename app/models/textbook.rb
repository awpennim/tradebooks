class Textbook < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  require 'isbn_app'
  include ISBN_app

  attr_accessor :isbn_str, :admin_create
  attr_accessible :isbn, :isbn_str, :suffix, :admin_create, :author, :title, :publisher_text, :summary

  has_many :sell_listings, :class_name => "Listing", :foreign_key => "textbook_id", :dependent => :delete_all, :order => 'updated_at DESC', :conditions => { :selling => true }
  has_many :buy_listings, :class_name => "Listing", :foreign_key => "textbook_id", :dependent => :delete_all, :order => 'updated_at DESC', :conditions => { :selling => false }

  has_many :twins, :class_name => "TextbookTwin"

  validates :isbn, :uniqueness => {:scope => :suffix, :message => "ISBN has already been created"},
                   :length => {:within => 0..10, :message => "ISBN is too long"}
  validates :author, :presence => {:message => "Author field is blank"}
  validates :title, :presence => {:message => "Title field is blank"},
                    :length => {:within => 0..255, :message => "Title is too long"}

  before_validation :fill_atts, :if => :need_fill?
  
  def update_attributes(params = {})

    params[:summary] = nil if params[:summary].blank?
    params[:publisher_text] = nil if params[:publisher_text].blank?
    params[:suffix] = nil if params[:suffix] == "0"

    self.author = params[:author]
    self.title = params[:title]
    self.summary = params[:summary]
    self.publisher_text = params[:publisher_text]
    self.suffix = params[:suffix]
    self.isbn = params[:isbn]

    self.save
  end

  def isbn_dsp
    temp = isbn.to_s

    str = ("0" * (10 - temp.length)) + temp

    if suffix
      str << "X"
      str[1..(str.length - 1)] #cuts out unnecessary "0" in the beginning
    else
      str
    end
  end

  def title_short
    if self.title.length > 40
      self.title[0..37] + "..."   
    else
      self.title
    end
  end

  private

    def need_fill?
      self.new_record?
    end

    def checkISBN!(value)
      if value.nil? || value.length == 0
        self.errors.add(:isbn, "field is blank")
	return false
      end

      value.gsub!('-', '')
      value.gsub!(' ', '')
      value.gsub!("\t",'')

      length = value.length

      if !(length === 10 || (length === 13 && value[0..2] === "978"))
        self.errors.add(:isbn, "must be 10 or 13 characters") 
        self.isbn = value #so error messages don't repeat
        return false
      end
      if value[0..(length - 2)].gsub(/[^0-9]/,'') + value[length - 1].sub(/[^(0-9)|(x|X)]/,'') != value
        self.errors.add(:isbn, 'can only contain spaces, numbers and hyphens(-) and in special cases they can end with an (X)')
        self.isbn = nil
        return false
      end

      #for some reason isbn_str = *** sets it to nil if the "if" statement is false. First 3 characters have already been checked.
      if length == 13 
        temp = value[3..12]
      else
        temp = value 
      end

      if !temp.index(/x|X/).nil?
        self.suffix = true
        self.isbn = temp[0..(temp.length - 2)] #removes the "x" so the int can save
      else
        self.isbn = temp.to_i
      end

      return value
    end

    def fill_atts
      if admin_create
        self.suffix = nil if self.suffix == false
        self.author = nil if self.author.blank?
	self.summary = nil if self.summary.blank?
	self.publisher_text = nil if self.publisher_text.blank?
        return true
      end

      if isbn_str.nil? || isbn_str.length == 0
        self.errors.add(:isbn, "field has no digits")
        return nil
      end

      temp = isbn_str
      return false unless temp = checkISBN!(isbn_str)
      isbn_str = temp
    
      search = Textbook.where(:isbn => self.isbn, :suffix => self.suffix).limit(1).first

      if search.nil? && TextbookTwin.where(:isbn => self.isbn, :suffix => self.suffix).limit(1).first.nil? == false
        search = TextbookTwin.where(:isbn => self.isbn, :suffix => self.suffix).limit(1).first.textbook
      end

      unless search.nil?
        self.id = search.id #already exists. Returns with the right id
        return false
      end

      book_data = book_data(:isbn => isbn_str)

      if book_data.nil?
        self.errors.add(:isbn, "We couldn't find a book with that ISBN number in our database. To request that we add it, please login, then #{ ActionController::Base.helpers.link_to 'click here', request_book_textbooks_path(:isbn => isbn_str) }")
        self.isbn = isbn_str
        return false
      end

      isbn_recieved = book_data["isbn"]
    
      if book_data["isbn"] != isbn_str && !isbn_recieved.nil? && isbn_recieved[0..(isbn_recieved.length - 2)].gsub(/[^0-9]/,'') + isbn_recieved[isbn_recieved.length - 1].sub(/[^(0-9)|(x|X)]/,'') == isbn_recieved #runs checks to make sure its a good number
        if checkISBN!(isbn_recieved) #if the found isbn is good then search database

          search = Textbook.where(:isbn => self.isbn, :suffix => self.suffix).limit(1).first

          if search.nil? && TextbookTwin.where(:isbn => self.isbn, :suffix => self.suffix).limit(1).first.nil? == false
	    search = TextbookTwin.where(:isbn => self.isbn, :suffix => self.suffix).limit(1).first.textbook
	  end

          unless search.nil?
            self.id = search.id
            return false
          end
        end
      end

      if book_data.nil? || book_data["Title"].nil? || book_data["AuthorsText"].nil?
        self.errors.add(:isbn, "couldn't be found in the database")
        return false
      else
        if book_data["TitleLong"]
          self.title = book_data["TitleLong"].to_s[0..256]
        else
        self.title = book_data["Title"].to_s[0..256]
        end

        if book_data["Summary"]
          self.summary = book_data["Summary"].to_s[0..1000]
        end

        self.author = book_data["AuthorsText"].to_s[0..256]
        self.publisher_text = book_data["PublisherText"].to_s[0..256]
      end
    end
end
