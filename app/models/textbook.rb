class Textbook < ActiveRecord::Base
  require 'isbn_app'
  include ISBN_app

  attr_accessor :isbn_str
  attr_accessible :isbn, :isbn_str

  validates :isbn, :uniqueness => {:scope => :suffix}
  validates :author, :presence => true
  validates :title, :presence => true

  before_validation :fill_atts, :if => :need_fill?

  
  def update_attributes(params = {})
    self.author = params[:author]
    self.title = params[:title]
    self.summary = params[:summary]
    self.publisher_text = params[:publisher_text]

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
      if isbn_str.nil? || isbn_str.length == 0
        self.errors.add(:isbn, "field has no digits")
        return nil
      end

      temp = isbn_str
      return false unless temp = checkISBN!(isbn_str)
      isbn_str = temp
    
      search = Textbook.find_by_isbn(self.isbn)

      unless search.nil?
        self.id = search.id #already exists. Returns with the right id
        return false
      end

      book_data = book_data(:isbn => isbn_str)

      if book_data.nil?
        self.errors.add(:isbn, "We couldn't find a book with that ISBN number in our database")
        self.isbn = isbn_str
        return false
      end

      isbn_recieved = book_data["isbn"]
    
      if book_data["isbn"] != isbn_str && !isbn_recieved.nil? && isbn_recieved[0..(isbn_recieved.length - 2)].gsub(/[^0-9]/,'') + isbn_recieved[isbn_recieved.length - 1].sub(/[^(0-9)|(x|X)]/,'') == isbn_recieved #runs checks to make sure its a good number
        if checkISBN!(isbn_recieved) #if the found isbn is good then search database
          search = Textbook.find_by_isbn(self.isbn)

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
