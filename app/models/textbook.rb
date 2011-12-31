class Textbook < ActiveRecord::Base
  include ISBN_app

  attr_accessible :isbn

  validates :isbn, :presence => true, :numericality => true , :length => {:is => 10}, :uniqueness => true
  validates :author, :presence => true
  validates :title, :presence => true

  def fill_atts!
    book_data = book_data(:isbn => isbn)
    puts book_data["AuthorsText"]
    puts book_data["Title"]
    self.title = book_data["Title"]
    self.author = book_data["AuthorsText"]
    true
  end
end
