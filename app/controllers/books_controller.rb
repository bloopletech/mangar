class BooksController < ItemsController
  def show
    @book = Book.find(params[:id])
    @book.open
  end
end