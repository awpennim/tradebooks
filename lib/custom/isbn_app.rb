require 'open-uri'
require 'rexml/document'

module ISBN_app

  ISBNDB_URL = "http://isbndb.com/api/books.xml?access_key=KT6GCO29"

  def book_data(hash)
    url = ISBNDB_URL.dup

    nothing = 1

    return nil if hash[:isbn] == nil

    url << ("&index1=isbn&value1=#{hash[:isbn].to_s}")

    doc = REXML::Document.new(getXML(url))

    hash = Hash.new

    doc.root.get_elements("BookList")[0].get_elements("BookData")[0].elements.each do |elem|
      hash["#{elem.name}"] = elem.text
    end

    hash
  end

  def stats
    doc = REXML::Document.new(getXML(ISBNDB_URL + "&results=keystats"))
  
    granted = doc.root.get_elements("KeyStats")[0].attribute("granted").to_s
    limit = doc.root.get_elements("KeyStats")[0].attribute("limit").to_s
    requests = doc.root.get_elements("KeyStats")[0].attribute ("requests").to_s\

    {:granted => granted, :limit => limit, :requests=> requests}
  end
  
  def stats_string
    data = stats
    ("granted: #{data[:granted]}, limit: #{data[:limit]}, requests: #    {data[:requests]}")
  end

  private 

  def getXML(s)
    page = open(s)
    web = page.read
    page.close
    web
  end
end
