class BooksImporter
  #Iterate recursively over all files/dirs
  #If current item is a zip/rar/cbr/cbz file, pull out first image and store zip filename as manga name and zip filename as filename to load.
  #Else if current item is a dir, and it contains images but no directories, store the dir name as the manga name as well as the load filename.
  #Else skip/recurse into dir.
  #Do not call more than once at a time
  def import_and_update
    path_list = Pathname.new(Mangar.import_dir).realpath.descendant_directories
    path_list.each { |path| BookImporter.new(path.to_s).import }

    #system("cd #{File.escape_name(Mangar.import_dir)} && find . -depth -type d -empty -exec rmdir {} \\;")
  end
end