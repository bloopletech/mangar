class BooksController < ApplicationController
  def index
    @books = if params[:tag] || params[:sort] || params[:sort_direction]
#      raise StandardError.new("Bad input") unless ['']
      (!params[:tag].blank? ? Book.tagged_with(params[:tag]) : Book).find(:all, :order => "#{params[:sort]} #{params[:sort_direction]}")
    else
      Book.all
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
    render :text => ""
  end
end