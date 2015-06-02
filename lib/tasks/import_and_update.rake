task import_and_update: :environment do
  BooksImporter.new.import_and_update
end