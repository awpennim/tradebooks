module ApplicationHelper
  def title
    base_title = "Trade Campus Books"
    if @title
      "#{base_title} | #{@title}" 
    else
      base_title
    end
  end

  def display_link(item, name)
    if item.size > 0
      return helper(name, true, item.size)
    else
      return helper(name, false, item.size)
    end
  end

  private

    def helper(name, not_zero,size)
      if name.to_sym == :notification
        if not_zero
          return "<li class='new_link'>#{ link_to pluralize(size, 'Notification'), notifications_user_path(current_user) }</li>"
	else
          return "<li>#{ link_to 'Notifications', notifications_user_path(current_user) }</li>"
	end
      elsif name.to_sym == :message
        if not_zero
          return "<li class='new_link'>#{ link_to pluralize(size, 'Message'), inbox_user_messages_path(current_user) }</li>"
	else
          return "<li>#{ link_to 'Messages', inbox_user_messages_path(current_user) }</li>"
	end
      elsif name.to_sym == :outbox
      end
    end
end
