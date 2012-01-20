class TextbooksController < ApplicationController
  before_filter :authenticate_admin, :only => [:index, :new, :update, :delete, :edit]
  before_filter :set_textbook, :only => [:show, :edit, :update, :destroy]
  before_filter :authenticate, :only => [:request]
  skip_before_filter :ensure_verified

  def index
    @title = "Textbooks in Database"
    @textbooks = Textbook.paginate(:page => params[:page])
  end

  def show
    @title = @textbook.title_short

    @looking_for_counter = @textbook.buy_listings.count
    @for_sale_counter = @textbook.sell_listings.count
    @listing = current_user.listing_from_textbook(@textbook.id) if logged_in?
  end

  def new
    @textbook = Textbook.new
    @title = "New Textbook"
  end

  def search
    @textbook = Textbook.new
    @title = "Search for Textbooks"
  end

  # GET /textbooks/1/edit
  def edit
    @textbook.isbn_str = @textbook.isbn_dsp
  end

  def request_book
    @isbn_str = params[:isbn]
    
    if @isbn_str.nil?
      redirect_to root_path
      return
    end

    UserMailer.send_textbook_request_to_admin(@isbn_str, current_user).deliver

    redirect_to textbooks_search_path, :notice => "Your request has been sent. You will be notified once this book has been added"
  end

  def create
    if params[:textbook].nil?
      redirect_to root_path
      return
    end
     
    @textbook = Textbook.new(params[:textbook])

    if @textbook.save
      redirect_to @textbook
    else
      if @textbook.id.nil?
        render textbooks_search_path
      else
        redirect_to textbook_path(@textbook.id)
      end
    end
  end

  def update
    if !@textbook.nil? && @textbook.update_attributes(params[:textbook])
      redirect_to(@textbook, :notice => 'Textbook was successfully updated.')
    else
      @textbook.isbn_str = @textbook.isbn_dsp
      render :edit 
    end
  end

  def destroy
    @textbook.destroy

    redirect_to textbooks_url
  end

  private

    def set_textbook
      @textbook = Textbook.find_by_id(params[:id])
      redirect_to root_path, :notice => "We couldn't find a textbook with that ID" if @textbook.nil?
    end
end
