class TextbooksController < ApplicationController
  def index
    @textbooks = Textbook.all
  end

  def show
    @textbook = Textbook.find(params[:id])
  end

  def new
    @textbook = Textbook.new
  end

  # GET /textbooks/1/edit
  def edit
    @textbook = Textbook.find(params[:id])
  end

  def create
    @textbook = Textbook.new(params[:textbook])

    if @textbook.fill_atts! && @textbook.save
      redirect_to @textbook
    else
      render new_textbook_path
    end
  end

  def update
    @textbook = Textbook.find(params[:id])

    if @textbook.update_attributes(params[:textbook])
      redirect_to(@textbook, :notice => 'Textbook was successfully updated.')
    else
      render edit_textbook_path(@textbook), :action => :edit 
    end
  end

  def destroy
    @textbook = Textbook.find(params[:id])

    @textbook.destroy

    redirect_to textbooks_url
  end
end
