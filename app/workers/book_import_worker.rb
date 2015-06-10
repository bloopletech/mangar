class BookImportWorker
  include Sidekiq::Worker

  def perform(path)
    BookImporter.new(Pathname.new(path)).import
  end
end