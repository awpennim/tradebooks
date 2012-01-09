module ApplicationHelper
  def title
    base_title = "Zoomass Textbooks"
    if @title
      "#{base_title} | #{@title}" 
    else
      base_title
    end
  end

  def display_link(item, name)
    if item.size > 0
      return "<li class='new_link'>#{ link_to pluralize(item.size, name.to_s.capitalize), helper(name) }</li>"
    else
      return "<li>#{ link_to name.to_s.capitalize, helper(name) }</li>"
    end
  end

  private

    def helper(name)
      if name.to_sym == :notification
        return notifications_user_path(current_user)
      elsif name.to_sym == :deal

      elsif name.to_sym == :offer

      end
    end
end
