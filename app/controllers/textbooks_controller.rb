class TextbooksController < ApplicationController
  before_filter :authenticate_admin, :only => [:index, :new, :update, :delete, :edit]
  skip_before_filter :ensure_verified

  def index
    @title = "Textbooks in Database"
    @textbooks = Textbook.all
  end

  def show
    @textbook = Textbook.find(params[:id])
    @title = @textbook.title
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
    @textbook = Textbook.find(params[:id])
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
    @textbook = Textbook.find_by_id(params[:id])

    if !@textbook.nil? && @textbook.update_attributes(params[:textbook])
      redirect_to(@textbook, :notice => 'Textbook was successfully updated.')
    else
      @textbook.isbn_str = @textbook.isbn_dsp
      render :edit 
    end
  end

  def destroy
    @textbook = Textbook.find(params[:id])

    @textbook.destroy

    redirect_to textbooks_url
  end
end
