module ApplicationHelper
  def title
    base_title = "Zoomass Textbooks"
    if @title
      "#{base_title} | #{@title}" 
    else
      base_title
    end
  end
end
