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
      return helper(name, true,item.size)
    else
      return helper(name, false, item.size)
    end
  end

  private

    def helper(name, plural,size)
      if name.to_sym == :notification
        if plural
          return "<li class='new_link'>#{ link_to pluralize(item.size, 'Notification'), notifications_user_path(current_user) }</li>"
	else
          return "<li>#{ link_to 'Notifications', notifications_user_path(current_user) }</li>"
	end
      elsif name.to_sym == :deal

      elsif name.to_sym == :offer

      end
    end
end
