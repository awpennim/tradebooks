module ApplicationHelper
  include ReCaptcha::ViewHelper

  def title
    base_title = "Trade Campus Books | UMass Amherst"
    if @title
      "#{base_title} | #{@title}" 
    else
      base_title
    end
  end

  def display_link(item, name)
    if item.size > 0
     count = item.size
     if name.to_sym == :offer
       item.each do |it|
         count = count - 1 if it.check_status! == false
       end

       return helper(name, false, count) if count < 1
       return helper(name, true, count)
     end

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
      elsif name.to_sym == :offer
        if not_zero
          return "<li class='new_link'>#{ link_to pluralize(size, 'Offer'), active_recieved_offers_user_path(current_user) }</li>"
	else
          return "<li>#{ link_to 'Offers', recieved_offers_user_path(current_user) }</li>"
	end
      elsif name.to_sym == :deal
        if not_zero
          return "<li class='new_link'>#{ link_to pluralize(size, 'Active Deal'), active_deals_user_path(current_user) }</li>"
	else
          return "<li>#{ link_to 'Deals', deals_user_path(current_user) }</li>"
	end
      end
    end
end
