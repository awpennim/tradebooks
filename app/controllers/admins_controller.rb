class AdminsController < ApplicationController
  before_filter :authenticate_admin

  def delete_faq
    @faq = Faq.find_by_id(params[:id])
    @faq.destroy
    redirect_to faq_path, :notice => "FAQ '#{@faq.question}' has been removed."
  end

  def create_faq
    @faq = current_user.faqs.build(params[:faq])

    if @faq.save
      redirect_to faq_path, :notice => "FAQ #{@faq.question} has been added"
    else
      @title = "Post FAQ"
      render :add_faq
    end
  end

  def add_faq
    @title = "Post FAQ"
    @faq = Faq.new
  end

  def index
    @title = "Administrator Home"
  end
end
