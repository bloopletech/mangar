class BooksController < ApplicationController
  def index
    if params[:tag] && params[:tag].present?
      @books = Book.tagged_with(params[:tag])
    else
      @books = Book.all
    end
  end

  def show
    @book = Book.find(params[:id])
    @book.increment!(:opens)
    system("open -a /Applications/Xee.app/Contents/MacOS/Xee #{File.escape_name(@book.real_directory)}")
    render :text => ""
  end

  def update
    @book = Book.find(params[:id])
    if @book.update_attributes(params[:book])
      render :action => 'update_fields'
    else
      #boom
    end
  end

  def import_and_update
    Thread.new do
      Book.import_and_update
    end
    render :action => 'import_and_update_started'
  end
end