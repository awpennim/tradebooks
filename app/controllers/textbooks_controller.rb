class TextbooksController < ApplicationController
  before_filter :authenticate_admin, :only => [:index, :new, :update, :delete, :edit]
  before_filter :set_textbook, :only => [:show, :edit, :update, :destroy]
  skip_before_filter :ensure_verified

  def index
    @title = "Textbooks in Database"
    @textbooks = Textbook.all
  end

  def show
    @title = @textbook.title

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
    end
end
