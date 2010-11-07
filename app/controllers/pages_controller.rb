class PagesController < ApplicationController
  before_filter :find_book

  def show
    id = params[:id].to_i - 1
    @page_url = @book.page_paths[id]
    @previous_page_url = book_page_path(@book, id) if id > 0
    @next_page_url = book_page_path(@book, id + 2) if id < (@book.page_paths.length - 1)   

    @title = @book.title
  end


  private
  def find_book
    @book = Book.find(params[:book_id])
  end
end