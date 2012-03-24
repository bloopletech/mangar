class BooksController < ItemsController
  def show
    @book = Book.find(params[:id])
    @book.open
    @page_title = @book.title
  end
end
