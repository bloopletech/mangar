require 'rails_helper'

RSpec.describe BookImporter do
  let(:book) { described_class.new(path) }

  describe '#relative_path' do
    let(:path) { File.realpath('spec/fixtures/import/temp/child') }
    before do
      allow(Mangar).to receive(:import_dir).and_return(File.realpath('spec/fixtures/import'))
    end

    specify do
      expect(book.relative_path.to_s).to eq('temp/child')
    end
  end
=begin
  describe '#relative_dir' do
    let(:path) { File.realpath('spec/fixtures/import/temp/child.zip') }
    before do
      allow(Mangar).to receive(:import_dir).and_return(File.realpath('spec/fixtures/import'))
    end

    specify do
      expect(book.relative_dir.to_s).to eq('temp/child')
    end
  end
=end

  describe '#destination_dir' do
    let(:path) { File.realpath('spec/fixtures/import/temp/child') }
    before do
      allow(Mangar).to receive(:import_dir).and_return(File.realpath('spec/fixtures/import'))
      allow(Mangar).to receive(:books_dir).and_return('spec/fixtures/books')
    end

    specify do
      expect(book.destination_dir.to_s).to eq('spec/fixtures/books/temp/child')
    end
  end

end