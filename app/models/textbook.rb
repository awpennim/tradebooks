class Textbook < ActiveRecord::Base
  require 'isbn_app'
  include ISBN_app

  attr_accessor :isbn_str
  attr_accessible :isbn, :isbn_str

  validates :isbn, :uniqueness => {:scope => :suffix}
  validates :author, :presence => true
  validates :title, :presence => true

  before_validation :fill_atts

  def fill_atts
    isbn_str.gsub!('-', '') unless isbn_str.nil?
    isbn_str.gsub!(' ', '') unless isbn_str.nil?


    length = isbn_str.length unless isbn_str.nil?

    if isbn_str.nil? || !(length === 10 || (length === 13 && isbn_str[0..2] === "978"))
      self.errors.add(:isbn, "must be 10 or 13 characters") 
      self.isbn = isbn_str #so error messages don't repeat
      return nil
    end
    if isbn_str[0..(length - 2)].gsub(/[^0-9]/,'') + isbn_str[length - 1].sub(/[^(0-9)|(x|X)]/,'') != isbn_str then
      self.isbn = -1
      return nil
    end

    #for some reason isbn_str = *** sets it to nil if the "if" statement is false. First 3 characters have already been checked.
    if length == 13 
      temp = isbn_str[3..12]
    else
      temp = isbn_str 
    end

    isbn_str = temp

    if !isbn_str.index(/x|X/).nil?
      self.suffix = true
      self.isbn = isbn_str[0..(isbn_str.length - 2)] #removes the "x" so the int can save
    else
      self.isbn = isbn_str.to_i
    end

    search = Textbook.find_by_isbn(self.isbn)

    unless search.nil?
      self.id = search.id
      return false
    end

    book_data = book_data(:isbn => isbn_str)

    isbn_recieved = book_data["isbn"]
    
    if !isbn_recieved.nil? && isbn_recieved[0..(isbn_recieved.length - 2)].gsub(/[^0-9]/,'') + isbn_recieved[isbn_recieved.length - 1].sub(/[^(0-9)|(x|X)]/,'') == isbn_recieved
      temp = isbn_recieved

      if !isbn_recieved.index(/x|X/).nil?
        self.suffix = true
        self.isbn = isbn_recieved[0..(isbn_recieved.length - 2)] #removes the "x" so the int can save
      else
        self.isbn = isbn_recieved.to_i
      end
    else
      temp = isbn_str
    end

    if temp != isbn_str
      puts "checking again"
      
      search = Textbook.find_by_isbn(self.isbn)

      unless search.nil?
        self.id = search.id
        return false
      end
    else
      isbn_str = temp
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
end
