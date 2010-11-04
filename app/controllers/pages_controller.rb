class PagesController < ApplicationController
  before_filter :find_book

  def show
    id = params[:id].to_i - 1
    @page_url = @book.page_urls[id]
    @next_page_url = book_page_path(@book, id + 2) if id < (@book.page_urls.length - 1)

    render :layout => 'page'
  end


  private
  def find_book
    @book = Book.find(params[:book_id])
  end
end